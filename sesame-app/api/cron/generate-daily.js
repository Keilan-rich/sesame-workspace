import { createClient } from '@supabase/supabase-js';

export const config = { maxDuration: 30 };

export default async function handler(req) {
  // Verify Vercel cron secret
  if (req.headers.get('authorization') !== `Bearer ${process.env.CRON_SECRET}`) {
    return new Response('Unauthorized', { status: 401 });
  }

  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
  );

  const today = new Date().toISOString().split('T')[0];

  // 1. Check if session already exists
  const { data: existing } = await supabase
    .from('daily_sessions')
    .select('id')
    .eq('date', today)
    .maybeSingle();

  if (existing) {
    return Response.json({ message: 'Session already exists', date: today });
  }

  // 2. Get calendar entry for today
  const { data: calEntry } = await supabase
    .from('calendar')
    .select('*')
    .eq('date', today)
    .maybeSingle();

  if (!calEntry) {
    return Response.json({ message: 'No calendar entry for today', date: today });
  }

  const subjects = calEntry.subjects || [];
  const qPerSubject = calEntry.questions_per_subject || 10;
  const sessionType = calEntry.session_type || 'daily';
  const timeMinutes = calEntry.time_minutes || 20;

  // 3. Check recent scores for adaptation
  const { data: recentResults } = await supabase
    .from('session_results')
    .select('subject, score, total')
    .order('created_at', { ascending: false })
    .limit(10);

  // Build a weakness map: subjects scoring < 50% get +5 extra questions
  const weakSubjects = new Set();
  if (recentResults) {
    const subjectScores = {};
    recentResults.forEach(r => {
      if (!subjectScores[r.subject]) subjectScores[r.subject] = { score: 0, total: 0 };
      subjectScores[r.subject].score += r.score;
      subjectScores[r.subject].total += r.total;
    });
    Object.entries(subjectScores).forEach(([subj, { score, total }]) => {
      if (total > 0 && (score / total) < 0.5) weakSubjects.add(subj);
    });
  }

  // 4. Select unused questions for each subject
  let selectedIds = [];
  for (const subject of subjects) {
    const limit = qPerSubject + (weakSubjects.has(subject) ? 5 : 0);
    const { data: questions } = await supabase
      .from('questions')
      .select('id')
      .eq('subject', subject)
      .eq('used', false)
      .limit(limit);

    if (questions && questions.length > 0) {
      selectedIds.push(...questions.map(q => q.id));
    } else {
      // If no unused questions, pick from previously wrong answers
      const { data: wrongResults } = await supabase
        .from('session_results')
        .select('wrong_answers')
        .eq('subject', subject)
        .order('created_at', { ascending: false })
        .limit(3);

      if (wrongResults) {
        const wrongIds = wrongResults
          .flatMap(r => (r.wrong_answers || []).map(w => w.id))
          .filter(Boolean);
        const uniqueWrong = [...new Set(wrongIds)].slice(0, limit);
        selectedIds.push(...uniqueWrong);
      }
    }
  }

  if (selectedIds.length === 0) {
    return Response.json({ message: 'No questions available', date: today });
  }

  // 5. Create the daily session
  const { error: insertError } = await supabase
    .from('daily_sessions')
    .insert({
      date: today,
      subjects,
      question_ids: selectedIds,
      session_type: sessionType,
      time_minutes: timeMinutes
    });

  if (insertError) {
    return Response.json({ error: insertError.message }, { status: 500 });
  }

  // 6. Mark questions as used
  await supabase
    .from('questions')
    .update({ used: true })
    .in('id', selectedIds);

  return Response.json({
    message: 'Daily session generated',
    date: today,
    subjects,
    questions_count: selectedIds.length
  });
}
