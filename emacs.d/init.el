(server-start)
(require 'package)

;; optional. makes unpure packages archives unavailable
(setq package-archives nil)

(setq package-enable-at-startup nil)
(package-initialize)

(setq org-caldav-file "/etc/nixos/emacs.d/org-caldav.el")
(load org-caldav-file)

(run-with-timer 0 (* 5 60) 'org-caldav-sync)
