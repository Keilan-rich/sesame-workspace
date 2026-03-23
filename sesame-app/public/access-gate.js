/**
 * Access Gate — Sésame 2026
 *
 * Bloque l'accès à l'app si l'utilisateur n'est pas autorisé.
 * Inclure ce script AVANT tout autre script dans chaque page protégée :
 *   <script src="/access-gate.js"></script>
 *
 * Requiert que Supabase JS soit chargé avant ce script.
 */
(function() {
  'use strict';

  // Emails autorisés (admin + utilisateurs payants)
  // Pour ajouter un utilisateur payant : ajouter son email ici
  const ALLOWED_EMAILS = [
    'kevinou1707@gmail.com'
  ];

  // Pages qui ne doivent PAS être bloquées
  const PUBLIC_PATHS = ['/paywall.html'];

  // Ne pas bloquer la page paywall elle-même
  if (PUBLIC_PATHS.some(p => window.location.pathname.endsWith(p))) return;

  // Masquer le body immédiatement pour éviter tout flash de contenu
  document.documentElement.style.visibility = 'hidden';

  const SUPABASE_URL = 'https://gkcxenxcyybgwdsgsuep.supabase.co';
  const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrY3hlbnhjeXliZ3dkc2dzdWVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM5MjcyMjMsImV4cCI6MjA4OTUwMzIyM30.fSS4MJpilWlfVyu6uPUKK-cWhO3S5KA_NUkKFLRPiBo';

  function checkAccess() {
    // Wait for Supabase to be available
    if (typeof window.supabase === 'undefined') {
      setTimeout(checkAccess, 50);
      return;
    }

    const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    sb.auth.getSession().then(function(result) {
      const session = result.data && result.data.session;
      const user = session && session.user;

      if (!user) {
        // Pas connecté — laisser index.html afficher l'overlay de login
        // Mais bloquer les autres pages
        if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
          document.documentElement.style.visibility = '';
        } else {
          window.location.replace('/');
        }
        return;
      }

      const email = (user.email || '').toLowerCase().trim();

      if (ALLOWED_EMAILS.includes(email)) {
        // Accès autorisé
        document.documentElement.style.visibility = '';
      } else {
        // Non autorisé — paywall
        window.location.replace('/paywall.html');
      }
    }).catch(function() {
      // En cas d'erreur réseau, bloquer par sécurité
      window.location.replace('/paywall.html');
    });
  }

  // Lancer le check dès que possible
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', checkAccess);
  } else {
    checkAccess();
  }
})();
