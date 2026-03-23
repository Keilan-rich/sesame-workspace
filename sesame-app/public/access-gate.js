/**
 * Access Gate — Sésame 2026
 *
 * Vérifie que l'utilisateur a payé via la table `profiles` dans Supabase.
 * Inclure APRÈS le script Supabase dans chaque page protégée :
 *   <script src="/access-gate.js"></script>
 *
 * Expose :
 *   window.__sesameCheckAccess(supabaseClient) → Promise<boolean>
 *   window.__sesameAllowed(email)              → true only for admin fallback
 */
(function() {
  'use strict';

  // Admin fallback (toujours accès même si la table profiles n'existe pas encore)
  var ADMIN_EMAIL = 'kevinou1707@gmail.com';

  window.__sesameAllowed = function(email) {
    return (email || '').toLowerCase().trim() === ADMIN_EMAIL;
  };

  /**
   * Vérifie si l'utilisateur courant a paid=true dans profiles.
   * @param {object} sb - Supabase client
   * @returns {Promise<boolean>}
   */
  window.__sesameCheckAccess = async function(sb) {
    try {
      const { data: { session } } = await sb.auth.getSession();
      if (!session?.user) return false;

      var email = (session.user.email || '').toLowerCase().trim();

      // Admin bypass (toujours OK)
      if (email === ADMIN_EMAIL) return true;

      // Check profiles table
      var { data, error } = await sb
        .from('profiles')
        .select('paid')
        .eq('id', session.user.id)
        .maybeSingle();

      // Si erreur (table n'existe pas encore, etc.) → bloquer par sécurité
      if (error || !data) return false;

      return data.paid === true;
    } catch (e) {
      return false;
    }
  };

  // ── Auto-gate : masquer + vérifier ──────────────────────

  var PUBLIC_PATHS = ['/paywall.html'];
  if (PUBLIC_PATHS.some(function(p) { return window.location.pathname.endsWith(p); })) return;

  // Masquer immédiatement
  document.documentElement.style.visibility = 'hidden';

  var SUPABASE_URL = 'https://gkcxenxcyybgwdsgsuep.supabase.co';
  var SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrY3hlbnhjeXliZ3dkc2dzdWVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM5MjcyMjMsImV4cCI6MjA4OTUwMzIyM30.fSS4MJpilWlfVyu6uPUKK-cWhO3S5KA_NUkKFLRPiBo';

  async function checkAccess() {
    if (typeof window.supabase === 'undefined') {
      setTimeout(checkAccess, 50);
      return;
    }

    var sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    var { data: { session } } = await sb.auth.getSession();

    if (!session?.user) {
      // Pas connecté — laisser index.html afficher le login
      if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
        document.documentElement.style.visibility = '';
      } else {
        window.location.replace('/');
      }
      return;
    }

    var allowed = await window.__sesameCheckAccess(sb);
    if (allowed) {
      document.documentElement.style.visibility = '';
    } else {
      window.location.replace('/paywall.html');
    }

    // Écouter les changements d'auth (login Google callback)
    sb.auth.onAuthStateChange(async function(event, session) {
      if (event === 'SIGNED_IN' && session?.user) {
        var ok = await window.__sesameCheckAccess(sb);
        if (!ok) window.location.replace('/paywall.html');
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', checkAccess);
  } else {
    checkAccess();
  }
})();
