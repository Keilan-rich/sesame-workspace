/**
 * Access Gate — Sésame 2026
 *
 * Bloque l'accès à l'app si l'utilisateur n'est pas autorisé.
 * Inclure ce script AVANT tout autre script dans chaque page protégée :
 *   <script src="/access-gate.js"></script>
 *
 * Expose window.__sesameAllowed(email) pour vérification inline.
 * Gère aussi le blocage initial (visibility:hidden + check session).
 */
(function() {
  'use strict';

  var ALLOWED_EMAILS = [
    'kevinou1707@gmail.com'
  ];

  // Expose globally so page scripts can check too
  window.__sesameAllowed = function(email) {
    return ALLOWED_EMAILS.includes((email || '').toLowerCase().trim());
  };

  window.__sesameGateRedirect = function() {
    window.location.replace('/paywall.html');
  };

  // Pages qui ne doivent PAS être bloquées
  var PUBLIC_PATHS = ['/paywall.html'];
  if (PUBLIC_PATHS.some(function(p) { return window.location.pathname.endsWith(p); })) return;

  // Masquer le contenu immédiatement
  document.documentElement.style.visibility = 'hidden';

  var SUPABASE_URL = 'https://gkcxenxcyybgwdsgsuep.supabase.co';
  var SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrY3hlbnhjeXliZ3dkc2dzdWVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM5MjcyMjMsImV4cCI6MjA4OTUwMzIyM30.fSS4MJpilWlfVyu6uPUKK-cWhO3S5KA_NUkKFLRPiBo';

  function checkAccess() {
    if (typeof window.supabase === 'undefined') {
      setTimeout(checkAccess, 50);
      return;
    }

    var sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    sb.auth.getSession().then(function(result) {
      var session = result.data && result.data.session;
      var user = session && session.user;

      if (!user) {
        if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
          document.documentElement.style.visibility = '';
        } else {
          window.location.replace('/');
        }
        return;
      }

      if (window.__sesameAllowed(user.email)) {
        document.documentElement.style.visibility = '';
      } else {
        window.location.replace('/paywall.html');
      }
    }).catch(function() {
      window.location.replace('/paywall.html');
    });

    // Also listen for auth changes (login after page load)
    sb.auth.onAuthStateChange(function(event, session) {
      if (event === 'SIGNED_IN' && session && session.user) {
        if (!window.__sesameAllowed(session.user.email)) {
          window.location.replace('/paywall.html');
        }
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', checkAccess);
  } else {
    checkAccess();
  }
})();
