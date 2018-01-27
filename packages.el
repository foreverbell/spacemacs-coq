;;; packages.el --- coq Layer packages File for Spacemacs
;;
;; Copyright (c) 2016 Tej Chajed
;;
;; Based on original version by Olivier Verdier
;;
;; Author: Tej Chajed <tchajed@mit.edu>
;; URL: https://github.com/tchajed/spacemacs-coq
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq coq-packages
    '(
      company-coq
      (proof-general :location local)
      ))

(setq coq-excluded-packages '())

(defun setup-coq-keys-for-map (state)
  (evil-define-key state coq-mode-map
    (kbd "C-<down>") #'proof-assert-next-command-interactive)
  (evil-define-key state coq-mode-map
    (kbd "C-<right>") #'company-coq-proof-goto-point)
  (evil-define-key state coq-mode-map
    (kbd "C-<up>") #'proof-undo-last-successful-command))

(defun setup-coq-keys ()
  (setup-coq-keys-for-map 'normal)
  (setup-coq-keys-for-map 'insert))

(defun hide-mode-statuses ()
  (diminish 'company-mode)
  (diminish 'hs-minor-mode)
  (diminish 'outline-minor-mode)
  (diminish 'company-mode)
  (diminish 'holes-mode))

(defun coq/init-company-coq ()
  (use-package company-coq
    :defer t
    :init
    (add-hook 'coq-mode-hook #'company-coq-mode)
    (add-hook 'coq-mode-hook #'setup-coq-keys)
    (add-hook 'coq-mode-hook #'hide-mode-statuses)
    (spacemacs/declare-prefix-for-mode
     'coq-mode
     "mi" "coq/insert")
    (spacemacs/set-leader-keys-for-major-mode 'coq-mode
      "il" 'company-coq-lemma-from-goal
      "im" 'company-coq-insert-match-construct)))

(defun coq/init-proof-general ()
  "Initialize Proof General."
  ;; Setup from Proof General README, using a specific path. Proof General
  ;; lazily loads from proof-site, so there's no need to use-package it.
  (load "~/.emacs.d/lisp/PG/generic/proof-site")
  (dolist (prefix '(("ml" . "pg/layout")
                    ("mp" . "pg/prover")
                    ("ma" . "pg/ask-prover")
                    ("mai" . "show-implicits")
                    ("man" . "show-all") ; n is for notation
                    ("mg" . "pg/goto")))
    (spacemacs/declare-prefix-for-mode
     'coq-mode
     (car prefix) (cdr prefix)))
  (spacemacs/set-leader-keys-for-major-mode 'coq-mode
    ;; Basic proof management
    "]" 'proof-assert-next-command-interactive
    "[" 'proof-undo-last-successful-command
    "." 'proof-goto-point
    ;; Layout
    "ll" 'proof-layout-windows
    "lc" 'pg-response-clear-displays
    "lp" 'proof-prf
    ;; Prover Interaction
    "px" 'proof-shell-exit
    "pc" 'proof-interrupt-process
    "pr" 'proof-retract-buffer
    "pb" 'proof-process-buffer
    ;; Prover queries ('ask prover')
    "af" 'proof-find-theorems
    "ap" 'coq-Print
    "ac" 'coq-Check
    "ab" 'coq-About
    "aip" 'coq-Print-with-implicits
    "aic" 'coq-Check-show-implicits
    "aib" 'coq-About-with-implicits
    "anp" 'coq-Print-with-all
    "anc" 'coq-Check-show-all
    "anb" 'coq-About-with-all
    ;; Moving the point (goto)
    "g." 'proof-goto-end-of-locked
    "ga" 'proof-goto-command-start
    "ge" 'proof-goto-command-end
    ;; Insertions
    "ie" 'coq-end-Section)
  ;; Workaround for evil performance bug (see
  ;; https://github.com/olivierverdier/spacemacs-coq/issues/6 for details).
  ;; Essentially the cursor color is changed rapidly when navigating the proof
  ;; in insert mode. This ensures the insert and normal mode colors are the
  ;; same, which generally avoids this problem.
  (add-hook 'coq-mode-hook
            (lambda ()
              (setq-local
               evil-insert-state-cursor
               (cons
                (car evil-normal-state-cursor)
                (cdr evil-insert-state-cursor))))))
