(defvar xc/pyside-modules
  '("QtCore" "Qt3DAnimation" "QtGui" "QtHelp" "QtNetwork" "QtOpenGL" "QtPrintSupport" "QtQml"
    "QtCharts" "QtQuick" "QtDataVisualization" "QtQuickWidgets" "QtTextToSpeech" "QtSql"
    "QtMultimedia" "QtMultimediaWidgets" "QtMacExtras" "QtSvg" "QtUiTools" "QtTest" "QtConcurrent"
    "QtAxContainer" "QtWebEngineCore" "QtWebEngineWidgets" "QtWebChannel" "QtWebSockets" "QtWidgets"
    "QtWinExtras" "QtX11Extras" "QtXml" "QtXmlPatterns" "Qt3DCore" "Qt3DExtras" "Qt3DInput" "Qt3DLogic"
    "Qt3DRender" "QtPositioning" "QtLocation" "QtSensors" "QtScxml")
  "List of Qt modules for use in `xc/pyside-lookup'.")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (load-theme 'modus-operandi)
(load-theme 'modus-vivendi-deuteranopia)

;; prevent custom from writing to init; have it write to a dump file
;; that never gets loaded or read
(setq custom-file "~/.emacs.d/custom-set.el")

;; TODO make interactive
(defun xc/load-directory (dir &optional ext)
  "Load all files in DIR with extension EXT.

Default EXT is \".el\".

See URL `https://www.emacswiki.org/emacs/LoadingLispFiles'"
  (let* ((load-it (lambda (f)
                    (load-file (concat (file-name-as-directory dir) f))))
         (ext (or ext ".el"))
         (ext-reg (concat "\\" ext "$")))
    (mapc load-it (directory-files dir nil ext-reg))))

(if (file-exists-p "~/lisp/")
    (xc/load-directory "~/lisp/"))

;; InnoSetup .iss files are basically ini files
(add-to-list 'auto-mode-alist '("\\.iss\\'" . conf-mode))

(add-to-list 'auto-mode-alist '("\\.hack.asm\\'" . hack-asm-mode))
(add-to-list 'auto-mode-alist '("\\.mak\\'" . makefile-mode))

;; configure autosave directory
;; https://stackoverflow.com/a/18330742/5065796
(defvar xc/-backup-directory (concat user-emacs-directory "backups"))
(if (not (file-exists-p xc/-backup-directory))
    (make-directory xc/-backup-directory t))
(setq backup-directory-alist `(("." . ,xc/-backup-directory))) ; put backups in current dir and in xc/-backup-directory
(setq make-backup-files t               ; backup of a file the first time it is saved.
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6               ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 9               ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t               ; auto-save every buffer that visits a file
      auto-save-timeout 20              ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200            ; number of keystrokes between auto-saves (default: 300)
      )

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment "utf-8")

;; tab insertion. See `xc/before-save-hook'.
(setq-default indent-tabs-mode nil)  ; don't ever insert tabs

(defun xc/before-save-hook ()
  "Conditionally run whitespace-cleanup before save.

Run whitespace-cleanup on save unless
`xc/disable-whitespace-cleanup' is non-nil.  Set
`xc/disable-whitespace-cleanup' using a directory local variable:

  ;; .dir-locals-2.el
  ((nil . ((xc/disable-whitespace-cleanup . t))))"
  (unless (or
           (and (boundp 'xc/disable-whitespace-cleanup) xc/disable-whitespace-cleanup)
           (eq major-mode 'makefile-mode))
    (whitespace-cleanup)))

(add-hook 'before-save-hook 'xc/before-save-hook)

(setq-default abbrev-mode t)
(delete-selection-mode 1)
(show-paren-mode 1)
(put 'narrow-to-region 'disabled nil)  ; enabling disables confirmation prompt
(setq initial-scratch-message nil)
(setq confirm-kill-emacs 'y-or-n-p)
(setq inhibit-startup-message t)
(setq initial-major-mode 'emacs-lisp-mode)
(setq help-window-select t)
;; (setq ring-bell-function 'ignore)
(setq initial-scratch-message "")
(setq show-help-function nil)
(set-default 'truncate-lines t)

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; don't prompt when calling dired-find-alternate-file
(put 'dired-find-alternate-file 'disabled nil)

;; Change yes-no prompts to y-n
(fset 'yes-or-no-p 'y-or-n-p)

;; Make occur window open in side-window
(setq
 display-buffer-alist
 '(("\\*Occur\\*"
    display-buffer-in-side-window
    (side . right)
    (slot . 0)
    (window-width . fit-window-to-buffer)
    )
   ))

;; Make *Occur* window size to the contents
(add-hook 'occur-hook
          (lambda ()
            (let ((fit-window-to-buffer-horizontally t))
              (save-selected-window
                (pop-to-buffer "*Occur*")
                (fit-window-to-buffer)))))

;; Make *Occur* window always open on the right side
(setq
 display-buffer-alist
 `(("\\*Occur\\*"
    display-buffer-in-side-window
    (side . right)
    (slot . 0)
    (window-width . fit-window-to-buffer))))

;; Automatically switch to *Occur* buffer
(add-hook 'occur-hook
          #'(lambda ()
              (switch-to-buffer-other-window "*Occur*")))

(defun xc/-maximize-occur-buffer (&optional &rest r)
  (if (string= (buffer-name (current-buffer)) "*Occur*")
      (maximize-window (get-buffer-window))))

(defun xc/-minimize-occur-buffer (&optional &rest r)
  (if (string= (buffer-name (current-buffer)) "*Occur*")
      (minimize-window (get-buffer-window))))

(advice-add 'other-window :after #'xc/-maximize-occur-buffer)
(advice-add 'other-window :before #'xc/-minimize-occur-buffer)
;; (advice-remove 'other-window 'xc/-maximize-occur-buffer)
;; (advice-remove 'other-window 'xc/-minimize-occur-buffer)

(advice-add 'occur-mode-goto-occurrence :before #'xc/-minimize-occur-buffer)
;; (advice-remove 'occur-mode-goto-occurrence 'xc/-minimize-occur-buffer)

;; split ediff vertically
(setq ediff-split-window-function 'split-window-right)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; restore window configuration on ediff close
;; https://emacs.stackexchange.com/a/17089
(defvar xc/ediff-last-windows nil)

(defun xc/store-pre-ediff-winconfig ()
  (setq xc/ediff-last-windows (current-window-configuration)))

(defun xc/restore-pre-ediff-winconfig ()
  (set-window-configuration xc/ediff-last-windows))

(add-hook 'ediff-before-setup-hook #'xc/store-pre-ediff-winconfig)
(add-hook 'ediff-quit-hook #'xc/restore-pre-ediff-winconfig)

(setq browse-url-browser-function 'eww-browse-url)
(setq eww-download-directory "/data/data/org.gnu.emacs/files")

(setq c-default-style "gnu")

(setq org-tree-slide-fold-subtrees-skipped nil)
(setq org-tree-slide-heading-emphasis t)
(setq org-tree-slide-header nil)
(setq org-tree-slide-never-touch-face nil)
(setq org-tree-slide-slide-in-effect nil)
(setq org-tree-slide-cursor-init nil)
(setq org-tree-slide-indicator nil)
(setq org-tree-slide-activate-message
      "Starting presentation...")

;; (setq visual-fill-column-width 110)
;; (setq visual-fill-column-center-text t)

;; (add-hook 'window-configuration-change-hook
;;          (lambda ()
;;            (set-window-margins (car (get-buffer-window-list (current-buffer) nil t)) 2)))

;; (with-eval-after-load 'org-faces
;;   (dolist (face '(org-document-title
;;                   org-level-1
;;                   org-level-2
;;                   org-level-3))
;;     (set-face-attribute face nil :height 1.0)))

(defun xc/play-hook ()
  ;; (tool-bar-mode -1)
  ;; (menu-bar-mode -1)
  ;; (set-face-attribute 'org-block-begin-line nil :foreground "#ffffff" :extend 't)
  ;; (set-face-attribute 'org-block-begin-line nil :foreground "#000000" :extend 't)
  ;; (setq-default cursor-type '(hbar . 1))
  ;; (setq-default cursor-type '(hollow . 1))
  ;; (setq-default cursor-type '(bar . 5))
  ;; (visual-fill-column-mode 1)
  ;; (visual-line-mode 1)
  )

(defun xc/stop-hook ()
  ;; (tool-bar-mode 1)
  ;; (menu-bar-mode 1)
  ;; (set-face-attribute 'org-block-begin-line nil :foreground 'unspecified :extend 't)
  ;; (setq-default cursor-type 't)
  ;; (visual-fill-column-mode 0)
  ;; (visual-line-mode 0)
  )


(add-hook 'org-tree-slide-play-hook 'xc/play-hook)
(add-hook 'org-tree-slide-stop-hook 'xc/stop-hook)

;; (scroll-bar-mode -1)
;; (tool-bar-mode -1)
;; (menu-bar-mode -1)
;; (display-time)

(setq global-hl-line-sticky-flag t)
(global-hl-line-mode 1)

(defalias 'xc/change-font-size #'text-scale-adjust)

;;; Mode line
(column-number-mode t)
(setq mode-line-position '((line-number-mode ("%l" (column-number-mode ":%c "))) (-3 "%p")))
(which-function-mode)

;; Just a hack, needs proper attention
(setq-default mode-line-format
              '("%e"
                mode-line-mule-info
                mode-line-modified
                " "
                mode-line-buffer-identification
                " "
                mode-line-position
                mode-line-misc-info
                (vc-mode vc-mode)
                " "
                mode-line-end-spaces))

;; Automatically reload files that have changed on disk
(global-auto-revert-mode)

;; make titlebar the filename
;; https://emacs.stackexchange.com/a/16836
(setq-default frame-title-format '("%f"))


(setq erc-nick "exc2")
(setq erc-user-full-name "excalamus")
(setq erc-port 6697)
(setq erc-default-server "irc.libera.chat")


(defun xc/-org-mode-config ()
  (setq org-adapt-indentation nil)
  (setq org-edit-src-content-indentation 0)
  (setq org-src-tab-acts-natively t)
  (setq org-src-fontify-natively t)
  (setq org-confirm-babel-evaluate nil)
  (setq org-support-shift-select 'always)
  (setq org-indent-indentation-per-level 0)
  (setq org-todo-keywords
        '((sequence
           ;; open items
           "TODO"                 ; todo, not active
           "CURRENT"              ; todo, active item
           "PENDING"              ; requires more information (timely)
           "|"  ; entries after pipe are considered completed in [%] and [/]
           ;; closed items
           "DONE"        ; completed successfully
           "ON-HOLD"     ; requires more information (indefinite time)
           "CANCELED"    ; no longer relevant, not completed
           )))

  (setq org-todo-keyword-faces
        '(
          ("TODO" . "light pink")
          ("CURRENT" . "yellow")
          ("DONE" . "light green")
          ("PENDING" . "light blue")
          ("ON-HOLD" . "plum")
          ("CANCELED" . "gray")
          ))

  (org-babel-do-load-languages
   'org-babel-load-languages
   '(
     (makefile . t)
     (python . t)
     (emacs-lisp . t)
     (latex . t)
     (shell . t)
     (scheme . t)
     (sql . t)
     (C . t)

     ))

  (defun xc/new-clock-task ()
    "Switch to new task by clocking in after clocking out."
    (interactive)
    (org-clock-out)
    (org-clock-in))

  ;; org-mode doesn't automatically save archive files for some
  ;; reason.  This is a ruthless hack which saves /all/ org buffers in
  ;; archive.  https://emacs.stackexchange.com/a/51112/15177
  (advice-add 'org-archive-subtree :after #'org-save-all-org-buffers))

(xc/-org-mode-config)

 ;; xref
(setq xref-prompt-for-identifier
      '(not xref-find-definitions
            xref-find-definitions-other-window
            xref-find-definitions-other-frame
            xref-find-references))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; extension
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun xc/backup-region-or-buffer (&optional buffer-or-name file beg end)
  "Write copy of BUFFER-OR-NAME between BEG and END to FILE.

BUFFER-OR-NAME is either a buffer object or name. Uses current
buffer when none is passed.  Uses entire buffer for region when
BEG and END are nil.  Prompts for filename when called
interactively.  Will always ask before overwriting. Returns the
name of the file written to.

See URL `https://stackoverflow.com/a/18780453/5065796'."
  (interactive)
  (let* ((buffer-or-name (or buffer-or-name (current-buffer)))
         (buffo (or (get-buffer buffer-or-name) (error "Buffer does not exist")))  ; buffer object
         (buffn (or (buffer-file-name buffo) (buffer-name buffo)))                 ; buffer name
         (beg (or beg (if (use-region-p) (region-beginning) beg)))
         (end (or end (if (use-region-p) (region-end) end)))
         (prompt (if (and beg end) "region" "buffer"))
         (new (if (called-interactively-p 'interactive)
                  (read-file-name
                   (concat "Write " prompt " to file: ")
                   nil nil nil
                   (and buffn (file-name-nondirectory buffn)))
                (or file (error "Filename cannot be nil"))))
         ;; See `write-region' for meaning of 'excl
         (mustbenew (if (and buffn (file-equal-p new buffn)) 'excl t)))
    (with-current-buffer buffo
      (if (and beg end)
          (write-region beg end new nil nil nil mustbenew)
        (save-restriction
          (widen)
          (write-region (point-min) (point-max) new nil nil nil mustbenew))))
    new))


(defun xc/define-abbrev (name expansion &optional fixed table interp)
  "Define abbrev with NAME and EXPANSION for last word(s) before point in TABLE.

FIXED sets case-fixed; default is nil.

TABLE defaults to `global-abbrev-table'.

Behaves similarly to `add-global-abbrev'.  The prefix argument
specifies the number of words before point that form the
expansion; or zero means the region is the expansion.  A negative
argument means to undefine the specified abbrev.  This command
uses the minibuffer to read the abbreviation.

Abbrevs are overwritten without prompt when called from Lisp.

\(fn NAME EXPANSION &optional FIXED TABLE)"
  (interactive
   (let* ((arg (prefix-numeric-value current-prefix-arg))
          (exp (and (>= arg 0)
                    (buffer-substring-no-properties
                     (point)
                     (if (= arg 0) (mark)
                       (save-excursion (forward-word (- arg)) (point))))))
          (name (read-string (format (if exp "Abbev name: "
                                       "Undefine abbrev: "))))
          (expansion (and exp (read-string "Expansion: " exp)))
          (table (symbol-value (intern-soft (completing-read
                                             "Abbrev table (global-abbrev-table): "
                                             abbrev-table-name-list nil t nil nil "global-abbrev-table"))))
          (fixed (and exp (y-or-n-p (format "Fix case? ")))))
     (list name expansion fixed table t)))
  (let ((table (or table global-abbrev-table))
        (fixed (or fixed nil)))
    (set-text-properties 0 (length name) nil name)
    (set-text-properties 0 (length expansion) nil expansion)
    (if (or (null expansion)                     ; there is expansion to set,
            (not (abbrev-expansion name table))  ; the expansion is not already defined
            (not interp)                         ; and we're not calling from code (calling interactively)
            (y-or-n-p (format "%s expands to \"%s\"; redefine? "
                              name (abbrev-expansion name table))))
        (define-abbrev table name expansion nil :case-fixed fixed))))

(defun xc/define-local-abbrev-table (definitions)
  "Define abbrev table with DEFINITIONS local to the current buffer.

Abbrev DEFINITIONS is a list of elements of the form (ABBREVNAME
EXPANSION ...) that are passed to `define-abbrev'.

Example:

    (xc/define-local-abbrev-table
       \'((\"TC\" \"triangular clique\" nil :case-fixed t)
        (\"banana\" \"rama\")
        ))

The local abbrev table has name of the current buffer appended
 with \"-abbrev-table\".

Use `xc/clear-local-abbrev-table' to remove local abbrev
definitions."
  (let* ((table-symbol (intern-soft (concat (buffer-name) "-abbrev-table"))))
    (define-abbrev-table table-symbol definitions)
    (setq-local local-abbrev-table (symbol-value table-symbol))
    (message "Created local abbrev table '%s'" table-symbol)))

(defun xc/clear-local-abbrev-table ()
  "Clear buffer-local abbrevs.

See `xc/define-local-abbrev-table'."
  (let* ((buffer-table-string (concat (buffer-name) "-abbrev-table"))
         (buffer-table-symbol (intern-soft buffer-table-string))
         (buffer-table (symbol-value buffer-table-symbol)))
    (cond ((abbrev-table-p buffer-table)
           (clear-abbrev-table buffer-table)
           (message "Cleared local abbrev table '%s'" buffer-table-string)))))


(defun xc/comint-exec-hook ()
  (interactive)
  (highlight-lines-matching-regexp "-->" 'xc/hi-comint)
  (setq comint-scroll-to-bottom-on-output t)
  (setq truncate-lines t)
  (set-window-scroll-bars (get-buffer-window (current-buffer)) nil nil 10 'bottom))

;; (add-hook 'comint-exec-hook #'xc/comint-exec-hook)


(defun xc/copy-symbol-at-point ()
  "Place symbol at point in `kill-ring'."
  (interactive)
  (let* ((bounds (bounds-of-thing-at-point 'symbol))
         (beg (car bounds))
         (end (cdr bounds))
         (sym (thing-at-point 'symbol)))
    (kill-ring-save beg end)
    (message "\"%s\"" sym)))


;; https://stackoverflow.com/a/21058075/5065796
(defun xc/create-scratch-buffer (&optional arg)
  "Create a new numbered scratch buffer.

Use prefix to prompt for command to run on new buffer."
  (interactive "p")
  (let (mode
        (n 0)
        bufname)
    (cond ((eql arg 1)  ; no prefix
           (setq mode #'emacs-lisp-mode))
          (t  ; C-u
           (setq mode (read-command "Command: "))))
    (while (progn
             (setq bufname (concat "*scratch"
                                   (if (= n 0) "" (int-to-string n))
                                   "*"))
             (setq n (1+ n))
             (get-buffer bufname)))
    (switch-to-buffer (get-buffer-create bufname))
    (funcall mode)))


;; https://stackoverflow.com/a/1110487
(eval-after-load "dired"
  '(progn
     (defun xc/dired-find-file (&optional arg)
       "Open each of the marked files, or the file under the
point, or when prefix arg, the next N files"
       (interactive "P")
       (mapc 'find-file (dired-get-marked-files nil arg)))
     (define-key dired-mode-map "F" 'xc/dired-find-file)))


(defun xc/duplicate-buffer (&optional dup)
  "Copy current buffer to new buffer named DUP.

Default DUP name is `#<buffer-name>#'."
  (interactive)
  (let* ((orig (buffer-name))
         (dup (or dup (concat "%" orig "%" ))))
    (if (not (bufferp dup))
        (progn
          (get-buffer-create dup)
          (switch-to-buffer dup)
          (insert-buffer-substring orig)
          (message "Duplicate buffer `%s' created" dup))
      (error "Duplicate buffer already exists"))))


(defun xc/kill-all-buffers-in-frame ()
  "Kill all buffers visible in selected frame."
  (interactive)
  (let ((buffer-save-without-query t))
    (walk-windows '(lambda (win) (kill-buffer (window-buffer win)))
                  nil (selected-frame))
    (delete-other-windows)))

(defun xc/kill-frame-and-buffers ()
  "Kill current frame along with its visible buffers."
  (interactive)
  (xc/kill-all-buffers-in-frame)
  (delete-frame nil t))


;; magit doesn't seem to revert buffers when creating a local copy of
;; a branch that exists on the remote. This happens when the branch is
;; made in BitBucket/GitHub or that someone has pushed up. The default
;; behavior of magit is supposed to auto revert all tracked files. You
;; would think that creating a local version of a remote branch would
;; do that, but it seems not. Maybe I'm getting myself mixed up?
(defun xc/revert-all-buffers (&optional arg)
  "Revert all file buffers.

Buffers visiting files that no longer exist are ignored.  Files
not readable (including do not exist) are ignored.  Other errors
are reported only as messages. Don't ask for confirmation when
called with a prefix.

See `https://emacs.stackexchange.com/a/24464/'"
  (interactive "p")
  (let ((noconfirm (if (= arg 1) nil t))
        (file))
    (dolist (buf (buffer-list))
      (setq file (buffer-file-name buf))
      (when (and file (file-readable-p file))
        (with-current-buffer buf
          (with-demoted-errors "Error: %S"
            (if (revert-buffer t noconfirm)
                (message "Reverted buffer from file: %s" file)
              (message "User canceled revert for buffer: %s" buf))))))))


(defun xc/reselect-last-region ()
  "Reselect the last region.

Taken from URL
`https://web.archive.org/web/20170118020642/http://grapevine.net.au/~striggs/elisp/emacs-homebrew.el'"
  (interactive)
  (let ((start (mark t))
        (end (point)))
    (goto-char start)
    (call-interactively 'set-mark-command)
    (goto-char end)))


(defun xc/get-file-name ()
  "Put filename of current buffer on kill ring."
  (interactive)
  (let ((filename (buffer-file-name (current-buffer))))
    (if filename
        (progn
          (kill-new filename)
          (message "%s" filename))
      (message "Buffer not associated with a file"))))


(defun xc/indent-current-file ()
  (interactive)
  (let ((filename (buffer-file-name (current-buffer))))
    (cond (filename
           (cond ((member major-mode '(c-mode c++-mode))
                  (save-buffer)
                  (call-process "indent" nil 0 nil filename)
                  (with-current-buffer (current-buffer)
                    (revert-buffer :ignore-auto :noconfirm :preserve-modes))
                  (message "Ran indent on: %s" filename))
                 (t
                  (message "Not visiting a C-style file")))))))


(defun xc/highlight-current-line ()
  (interactive)
  (let ((regexp
         (regexp-quote
          (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
        (face (hi-lock-read-face-name)))
    (highlight-lines-matching-regexp regexp face)))


;; https://emacs.stackexchange.com/questions/66849/how-to-move-to-the-next-highlight
(defun xc/next-highlight (&optional hl)
  "Move point before first following character highlighted or end of buffer"
  (interactive  (list
                 ;; (hi-lock-read-face-name)
                 'hi-yellow
                 ))
  (while(let ((fc (get-text-property (point)'face) ))
          (and (consp fc )(memq hl fc) ))
    (forward-char))
  (while (let ((fc (get-text-property (point)'face) ))
           (or (not (consp fc )) (not (memq hl fc))))
    (forward-char)))


;; https://emacs.stackexchange.com/questions/66849/how-to-move-to-the-next-highlight
(defun xc/previous-highlight (&optional hl)
  "Moves point before first following character highlighted or end of buffer"
  (interactive  (list
                 ;; (hi-lock-read-face-name)
                 'hi-yellow
                 ))
  (while(let ((fc (get-text-property (point)'face) ))
          (and (consp fc )(memq hl fc) ))
    (backward-char))
  (while (let ((fc (get-text-property (point)'face) ))
           (or (not (consp fc )) (not (memq hl fc))))
    (backward-char)))


(defun xc/Info-link-to-current-node (&optional arg)
  "Format current info node as url.

With no prefix, place the url corresponding to the current Info
node into the kill ring.

With universal prefix, visit url with default web browser and do
not put url into the kill ring.

With numeric prefix, create Org link with node name as
description into the kill ring."
  (interactive "p")
  (unless Info-current-node
    (user-error "No current Info node"))
  (let* ((info-file (if (stringp Info-current-file)
                        (file-name-sans-extension
                         (file-name-nondirectory Info-current-file))))
         (node Info-current-node)
         (url (cond
               ((or (string= info-file "emacs") (string= info-file "org"))
                (concat "https://www.gnu.org/software/emacs/manual/html_node/"
                        info-file "/"
                        (if (string= node "Top") ""
                          (concat (replace-regexp-in-string " " "-" node t) ".html"))))
               ((string= info-file "guile")
                (concat "https://www.gnu.org/software/guile/manual/html_node/"
                        (if (string= node "Top") ""
                          (concat (replace-regexp-in-string " " "-" node t) ".html"))))
               ((string= info-file "guix")
                (concat "https://guix.gnu.org/en/manual/devel/en/html_node/"
                        (if (string= node "Top") ""
                          (concat (replace-regexp-in-string " " "-" node t) ".html"))))
               )))
    (cond
     ((eq arg 1)  ; no prefix
      (kill-new url)
      (message "%s" (car kill-ring)))
     ((eq arg 4)  ; universal prefix
      (browse-url-default-browser url))
     (t           ; any other prefix
      (kill-new (format "[[%s][%s]]" url node))
      (message "%s" (car kill-ring))))))


(defun xc/search (&optional prefix engine beg end)
  "Search the web for something.

If a region is selected, lookup using region defined by BEG and
END.  When no region or issue given, try using the thing at
point.  If there is nothing at point, ask for the search query."
  (interactive)
  (let* ((engine-list `(("duck" . "https://duckduckgo.com/?q=%s")
                        ("qgis" . "https://qgis.org/pyqgis/master/search.html?check_keywords=yes&area=default&q=%s")
                        ("sdl-wiki" . "https://wiki.libsdl.org/wiki/search/?q=%s")
                        ("sdl" . "https://wiki.libsdl.org/%s")
                        ("jira" . ,(concat xc/atlassian "%s"))))
         (beg (or beg (if (use-region-p) (region-beginning)) nil))
         (end (or end (if (use-region-p) (region-end)) nil))
         (thing (thing-at-point 'symbol t))
         (lookup-term (cond ((and beg end) (buffer-substring-no-properties beg end))
                            (thing thing)
                            (t (read-string "Search for: "))))
         (engine (or engine (completing-read "Select search engine: " engine-list nil t (caar engine-list))))
         (query (if prefix (format "%s %s" prefix lookup-term) lookup-term))
         (search-string (url-encode-url (format (cdr (assoc engine engine-list)) query))))
      (browse-url-default-browser search-string)))

(defun xc/search-duck (&optional beg end)
  (interactive)
  (xc/search nil "duck" beg end))

(defun xc/search-jira (&optional beg end)
  (interactive)
  (xc/search nil "jira" beg end))

(defun xc/search-qgis (&optional beg end)
  (interactive)
  (xc/search nil "qgis" beg end))

(defun xc/search-Qt (&optional beg end)
  (interactive)
  (xc/search nil "Qt" beg end))

(defun xc/search-sdl (&optional beg end)
  (interactive)
  (xc/search nil "sdl" beg end))

(defun xc/search-sdl-wiki (&optional beg end)
  (interactive)
  (xc/search nil "sdl-wiki" beg end))


(defun minibuffer-inactive-mode-hook-setup ()
  "Allow autocomplete in minibuffer.

Make `try-expand-dabbrev' from `hippie-expand' work in
mini-buffer @see `he-dabbrev-beg', so we need re-define syntax
for '/'.  This allows \\[dabbrev-expand] to be used for
expansion.

Taken from URL
`https://blog.binchen.org/posts/auto-complete-word-in-emacs-mini-buffer-when-using-evil.html'"
  (set-syntax-table (let* ((table (make-syntax-table)))
                      (modify-syntax-entry ?/ "." table)
                      table)))

(add-hook 'minibuffer-inactive-mode-hook 'minibuffer-inactive-mode-hook-setup)


(defun xc/narrow-to-defun-indirect (&optional arg)
  "Narrow to function or class with preceeding comments.

Open in other window with prefix.  Enables
`which-function-mode'."
  (interactive "P")
  (deactivate-mark)
  (which-function-mode t)
  (let* ((name (concat (buffer-name) "<" (which-function) ">"))
         (clone-indirect-fun (if arg 'clone-indirect-buffer-other-window 'clone-indirect-buffer))
         (switch-fun (if arg 'switch-to-buffer-other-window 'switch-to-buffer))
         ;; quasi-quote b/c name gets passed as symbol otherwise
         (buf (apply clone-indirect-fun `(,name nil))))
    (with-current-buffer buf
      (narrow-to-defun arg))
    ;; both switch-fun and buf are symbols
    (funcall switch-fun buf)))


(defun xc/newline-without-break-of-line ()
  "Create a new line without breaking the current line and move
the cursor down."
  (interactive)
  (let ((oldpos (point)))
    (end-of-line)
    (newline-and-indent)))


(defun xc/punch-timecard ()
  "Clock in or clock out.

Assumes a 'timecard.org' file exists with format:

    #+TITLE: Timecard
    #+AUTHOR: Excalamus

    DISPLAY CLOCK

    * Report
    #+BEGIN: clocktable :scope file :maxlevel 2 :block thisweek
    #+CAPTION: Clock summary at [2021-08-18 Wed 12:51], for week 2021-W33.
    | Headline       | Time    |      |
    |----------------+---------+------|
    | *Total time*   | *19:27* |      |
    |----------------+---------+------|
    | Timecard       | 19:27   |      |
    | \_  2021/08/18 |         | 3:59 |
    | \_  2021/08/17 |         | 8:27 |
    | \_  2021/08/16 |         | 7:01 |
    #+END:

    * Timecard

    * Local Variables
    # Local Variables:
    # eval: (defun xc/-button-pressed (&optional button) (interactive) (org-clock-display))
    # eval: (define-button-type 'display-clock-button 'follow-link t 'action #'org-clock-display)
    # eval: (make-button 45 58 :type 'display-clock-button)
    # eval: (setq org-duration-format 'h:mm)
    # End:"
  (interactive)
  (if (not (featurep 'org-clock))
      (require 'org-clock))
  (if (not (get-buffer "timecard.org"))
      (progn
        ;; (find-file "c:/Users/mtrzcinski/Documents/notes/timecard.org")
        (find-file "/home/ahab/Documents/notes/timecard.org")
        (previous-buffer)))
  (with-current-buffer "timecard.org"
    (let* ((buffer-save-without-query t)
           (time-string "%Y/%m/%d")
           (system-time-locale "en_US")
           (todays-date (format-time-string time-string))
           (header-regexp (format "\\*\\* %s" todays-date)))
      (save-excursion
        (goto-char (point-min))
        (if (re-search-forward header-regexp nil t)
            ;; found
            (progn
              ;; clock in or out accordingly
              (if (org-clocking-p)
                  (progn
                    (org-clock-out)
                    (setq result (format "Clocked out at %s [%s]"
                                         (format-time-string "%-I:%M %p" (current-time))
                                         (org-duration-from-minutes (org-clock-get-clocked-time)))))
                (progn
                  (org-clock-in)
                  (setq result (format "Clocked in at %s [%s]"
                                       (format-time-string "%-I:%M %p" (current-time))
                                       (org-duration-from-minutes (org-clock-get-clocked-time))))))
              (save-buffer)
              (message "%s" result))
          ;; not found
          (progn
            ;; insert subtree with today's date and try punching in
            (goto-char (point-min))
            (re-search-forward "* Timecard")
            (insert (format "\n** %s" todays-date))
            (xc/punch-timecard)))))))


(defun xc/on-demand-window-set ()
  "Set the value of the on-demand window to current window."
  (interactive)
  (setq xc/on-demand-window (selected-window))
  ;; (setq xc/on-demand-buffer (current-buffer))
  (message "Set on-demand window to: %s" xc/on-demand-window))


(defun xc/on-demand-window-goto ()
  "Goto `xc/on-demand-window' with `xc/on-demand-buffer'."
  (interactive)
  (let ((win xc/on-demand-window))
    (unless win (error "No on-demand window set! See `xc/on-demand-window-set'."))
    (if (eq (selected-window) xc/on-demand-window)
        (error "Already in `xc/on-demand-window'"))
    (let ((frame (window-frame win)))
      (raise-frame frame)
      (select-frame frame)
      (select-window win))))


;;.(defun xc/open-file-browser (&optional file)
;;.  "Open file explorer to directory containing FILE.
;;.
;;.FILE may also be a directory."
;;.  (interactive)
;;.  (let* ((file (or file (buffer-file-name (current-buffer)) default-directory))
;;.         (dir (expand-file-name (file-name-directory file))))
;;.    (if dir
;;.        (progn
;;.          (if (eq xc/device 'windows)
;;.              (browse-url-default-browser dir)
;;.            (start-process "thunar" nil "/run/current-system/profile/bin/thunar" file)))
;;.      (error "No directory to open"))))


;; (defun xc/open-terminal (&optional file)
;;   "Open external terminal in directory containing FILE.
;;
;; FILE may also be a directory.
;;
;; See URL `https://stackoverflow.com/a/13509208/5065796'"
;;   (interactive)
;;   (let* ((file (or (buffer-file-name (current-buffer)) default-directory))
;;          (dir (expand-file-name (file-name-directory file))))
;;     (cond ((eq xc/device 'windows)
;;            (let (;; create a cmd to create a cmd in desired directory
;;                  ;; /C Carries out the command specified by string and then stops.
;;                  ;; /K Carries out the command specified by string and continues.
;;                  ;; See URL `https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cmd'
;;                  (proc (start-process "cmd" nil "cmd.exe" "/C" "start" "cmd.exe" "/K" "cd" dir)))
;;              (set-process-query-on-exit-flag proc nil)))
;;           (t (start-process "terminal" nil "/run/current-system/profile/bin/xfce4-terminal" (format "--working-directory=%s" dir))))))


(defun xc/org-babel-goto-tangle-file ()
  "Open tangle file associated with source block at point.

Taken from URL `https://www.reddit.com/r/emacs/comments/jof1p3/visit_tangled_file_with_orgopenatpoint/'
"
  (interactive)
  (if-let* ((args (nth 2 (org-babel-get-src-block-info t)))
            (tangle (alist-get :tangle args)))
      (when (not (equal "no" tangle))
        (ffap-other-window tangle)
        t)))


(defun xc/pop-buffer-into-frame (&optional arg)
  "Pop current buffer into its own frame.

With ARG (\\[universal-argument]) maximize frame."
  (interactive "P")
  (let ((win (display-buffer-pop-up-frame (current-buffer) nil)))
    (if (and arg win)
        (progn
          (select-frame (car (frame-list)))
          (toggle-frame-maximized) ))))


(defun xc/rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME.

See URL `http://steve.yegge.googlepages.com/my-dot-emacs-file'"
  (interactive "GNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))


(defun xc/delete-file-visiting ()
  "Trash the file currently being visited.

Prompt to kill active buffer."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (progn
        (delete-file filename t)
        (cond ((not (file-exists-p filename))
               (message "Deleted %s" filename)
               (call-interactively 'kill-buffer))
              (message "Error deleting %s" filename))))))


(defun xc/send-line-or-region (&optional advance buff beg end)
  "Send region or line to BUFF.

If buffer has a process, insert and send line to the process. If
no process, then simply insert text at point.  Create a new line
when ADVANCE is non-nil.  Use current region if BEG and END not
provided.  If no region provided, send entire line.  Default BUFF
is the buffer associated with `xc/on-demand-window'."
  (interactive (if (use-region-p)
                   (list nil nil (region-beginning) (region-end))
                 (list nil nil nil nil)))
  (let* ((beg (or beg (if (use-region-p) (region-beginning)) nil))
         (end (or end (if (use-region-p) (region-end)) nil))
         (substr (string-trim
                  (or (and beg end (buffer-substring-no-properties beg end))
                      (buffer-substring-no-properties (line-beginning-position) (line-end-position)))))
         (buff (or buff (window-buffer xc/on-demand-window)))
         (proc (get-buffer-process buff)))
    (if substr
        (with-selected-window (get-buffer-window buff t)
          (let ((window-point-insertion-type t))  ; advance marker on insert
            (cond (proc
                   (goto-char (process-mark proc))
                   (insert substr)
                   (comint-send-input nil t))
                  (t
                   (insert substr)
                   (if advance
                       (progn
                         (end-of-line)
                         (newline-and-indent)))))))
      (error "Invalid selection"))))


(defvar xc--send-string-history nil
  "History of strings sent via `xc/send-string'")

(defun xc/send-string (string &optional advance buff)
  "Send STRING to BUFF'.

Default BUFF is the buffer associated with
`xc/on-demand-window' (or current window if not set).  If BUFF
has an associated process, send region as input, otherwise just
insert the region.  Create a new line when ADVANCE is non-nil."
  (interactive
   (let* ((prompt (format "Send string to %s: " (window-buffer xc/on-demand-window)))
          (cmd (read-string prompt "" 'xc--on-demand-send-string-history)))
     (list cmd nil nil)))

  (let* ((buff (or buff (window-buffer xc/on-demand-window)))
         (proc (get-buffer-process buff)))
    (with-selected-window (get-buffer-window buff t)
      (let ((window-point-insertion-type t))  ; advance marker on insert
        (cond (proc
               (goto-char (process-mark proc))
               (insert string)
               (comint-send-input nil t))
              (t
               (insert string)
               (if advance
                   (progn
                     (end-of-line)
                     (newline-and-indent)))))))))


(defun xc/smart-beginning-of-line ()
  "Move point to first non-whitespace character or to the beginning of the line.

Move point to the first non-whitespace character on this line.
If point was already at that position, move point to beginning of
line.

See URL `https://stackoverflow.com/a/145359'"
  (interactive)
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
         (beginning-of-line))))


(defun xc/switch-to-last-window ()
  "Switch to most recently used window.

See URL `https://emacs.stackexchange.com/a/7411/15177'"
  (interactive)
  (let ((win (get-mru-window t t t)))
    (unless win (error "Last window not found"))
    (let ((frame (window-frame win)))
      (raise-frame frame)
      (select-frame frame)
      (select-window win))))

;; 
;; (defun xc/suicide ()
;;   "Kill current Emacs process and children."
;;   (interactive)
;;   (let ((cmd (if (eq xc/device 'gnu)
;;                  "killall -9 -r emacs" ; probably won't kill server administered by systemd
;;                "taskkill /f /fi \"IMAGENAME eq emacs.exe\" /fi \"MEMUSAGE gt 15000\"")))
;;     (shell-command cmd)))


(defun xc/toggle-plover ()
  "Toggle whether Plover is active."
  (interactive)
  (if xc/plover-enabled
      (progn
        (setq xc/plover-enabled nil)
        (message "Plover disabled"))
    (progn
      (setq xc/plover-enabled t)
      (message "Plover enabled"))))


(defun xc/toggle-comment-contiguous-lines ()
  "(Un)comment contiguous lines around point."
  (interactive)
  (let ((pos (point)))
    (mark-paragraph)
    (forward-line)
    (comment-or-uncomment-region (region-beginning) (region-end))
    (goto-char pos)))


(defun xc/unfill-paragraph (&optional region)
  "Make multi-line paragraph into a single line of text.

REGION unfills the region.  See URL
`https://www.emacswiki.org/emacs/UnfillParagraph'"
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))


(defun xc/yank-pop-forwards (arg)
  "Pop ARGth item off the kill ring.

See URL `https://web.archive.org/web/20151230143154/http://www.emacswiki.org/emacs/KillingAndYanking'"
  (interactive "p")
  (yank-pop (- arg)))


(defun xc/minimize-window (&optional window)
  (interactive)
  (setq window (window-normalize-window window))
  (window-resize
   window
   (- (window-min-delta window nil nil nil nil nil window-resize-pixelwise))
   nil nil window-resize-pixelwise))

(defun xc/1/4-window (&optional window)
  (interactive)
  (setq window (window-normalize-window window))
  (xc/maximize-window)
  (window-resize
   window
   (- (- (window-min-delta window nil nil nil nil nil window-resize-pixelwise))
      (/ (- (window-min-delta window nil nil nil nil nil window-resize-pixelwise)) 4))
   nil nil window-resize-pixelwise))

(defun xc/center-window (&optional window)
  (interactive)
  (setq window (window-normalize-window window))
  (xc/maximize-window)
  (window-resize
   window
   (/ (- (window-min-delta window nil nil nil nil nil window-resize-pixelwise)) 2)
   nil nil window-resize-pixelwise))

(defun xc/3/4-window (&optional window)
  (interactive)
  (setq window (window-normalize-window window))
  (xc/maximize-window)
  (window-resize
   window
   (/ (- (window-min-delta window nil nil nil nil nil window-resize-pixelwise)) 4)
   nil nil window-resize-pixelwise))

(defun xc/maximize-window (&optional window)
  (interactive)
  (setq window (window-normalize-window window))
  (window-resize
   window (window-max-delta window nil nil nil nil nil window-resize-pixelwise)
   nil nil window-resize-pixelwise))

(setq xc/last-window-op 'center)

(defun xc/recenter-window-top-bottom (&optional arg)
  (interactive "P")

  ;; ;; center-max-3/4-1/4-min
  ;; (cond ((eq xc/last-window-op 'center)
  ;;        (xc/maximize-window)
  ;;        (setq xc/last-window-op 'max))
  ;;       ((eq xc/last-window-op 'max)
  ;;        (xc/3/4-window)
  ;;        (setq xc/last-window-op 'three-quarter))
  ;;       ((eq xc/last-window-op 'three-quarter)
  ;;        (xc/1/4-window)
  ;;        (setq xc/last-window-op 'one-quarter))
  ;;       ((eq xc/last-window-op 'one-quarter)
  ;;        (xc/minimize-window)
  ;;        (setq xc/last-window-op 'min))
  ;;       ((eq xc/last-window-op 'min)
  ;;        (xc/center-window)
  ;;        (setq xc/last-window-op 'center))))

  ;; min-1/4-center-3/4-max
  (cond ((eq xc/last-window-op 'min)
         (xc/1/4-window)
         (setq xc/last-window-op 'one-quarter))
        ((eq xc/last-window-op 'one-quarter)
         (xc/center-window)
         (setq xc/last-window-op 'center))
        ((eq xc/last-window-op 'center)
         (xc/3/4-window)
         (setq xc/last-window-op 'three-quarter))
        ((eq xc/last-window-op 'three-quarter)
         (xc/maximize-window)
         (setq xc/last-window-op 'max))
        ((eq xc/last-window-op 'max)
         (xc/minimize-window)
         (setq xc/last-window-op 'min))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; extension-ledger
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun xc/ledger-kill-current-transaction (pos)
  "Kill transaction surrounding POS."
  (interactive "d")
  (let ((bounds (ledger-navigate-find-xact-extents pos)))
    (kill-region (car bounds) (cadr bounds))
    (message "Killed current transaction")))


(defun xc/ledger-kill-ring-save-current-transaction (pos)
  "Save transaction surrounding POS to kill ring without
killing."
  (interactive "d")
  (let ((bounds (ledger-navigate-find-xact-extents pos)))
    (kill-ring-save (car bounds) (cadr bounds))
    (message "Placed on kill ring")))

(defun xc/balance-at-point ()
  "Get balance of account at point"
  (interactive)
  (let* ((account (ledger-context-field-value (ledger-context-at-point) 'account))
         (buffer (find-file-noselect (ledger-master-file)))
         (balance (with-temp-buffer
                    (apply 'ledger-exec-ledger buffer (current-buffer) "cleared" account nil)
                    (if (> (buffer-size) 0)
                        (buffer-substring-no-properties (point-min) (1- (point-max)))
                      (concat account " is empty.")))))
    (when balance
      (message balance))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; extension-python
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun xc/convert-slashes (&optional prefix beg end)
  "Convert backslashes to forward slashes and vice-versa.


Convert forward slashes to backslashes with prefix; backslashes
to forward slashes otherwise.  Only convert within region defined
by BEG and END.  Use current line if no region is provided."
  (interactive "p")
  (let* ((beg (or beg (if (use-region-p) (region-beginning)) (line-beginning-position)))
         (end (or end (if (use-region-p) (region-end)) (line-end-position))))
    (cond ((not (= prefix 1))
           (subst-char-in-region beg end ?/ ?\\))
          ;; (replace-string "/" "\\" nil beg end))
          (t
           (subst-char-in-region beg end ?\\ ?/)
           ;; (replace-string "//" "/" nil beg end)
           ))))

;; 
;; (defvar xc/kill-python-p t
;;   "Will Python be killed?")
;;
;; (if (eq xc/device 'gnu)
;;     (setq xc/kill-python-p nil))


(defun xc/toggle-kill-python ()
  (interactive)
  (if xc/kill-python-p
      (progn
        (setq xc/kill-python-p nil)
        (message "Python will be spared"))
    (progn
      (setq xc/kill-python-p t)
      (message "Python will be killed henceforth"))))


(defun xc/conda-activate ()
  "Activate conda venv."
  (interactive)
  (insert "C:\\Users\\mtrzcinski\\Anaconda3\\condabin\\conda.bat activate "))


(defun xc/mamba-activate ()
  "Activate mamba venv."
  (interactive)
  (insert "C:\\python\\miniconda39\\condabin\\mamba.bat activate "))


(setq xc/python-break-string "breakpoint()")
;; (setq xc/python-break-string "import ipdb; ipdb.set_trace(context=10)")
;; (setq xc/python-break-string "import mydebugger; mydebugger.breakpoint()")
;; (setq xc/python-break-string "import my_other_debugger; my_other_debugger.breakpoint()")
;; (setq xc/python-break-string "import pydevd_pycharm; pydevd_pycharm.settrace('localhost', port=53100, stdoutToServer=True, stderrToServer=True)")

(defun xc/insert-breakpoint (&optional string)
  (interactive)
  (let ((breakpoint (or string string xc/python-break-string)))
    (xc/newline-without-break-of-line)
    (insert breakpoint)
    (bm-toggle)
    (save-buffer)))


(defun xc/kill-proc-child (&optional proc-buffer)
  "Kill any child process associated with BUFFER-NAME."
  (interactive)
  (let* ((proc-buffer (or proc-buffer "*shell*"))
         (proc (get-buffer-process proc-buffer))
         (shell-pid (if proc (process-id proc)))
         (child-pid (if shell-pid (car (split-string
                                        (shell-command-to-string (format "pgrep --parent %d" shell-pid))))))
         rv)
    ;; (message "shell-pid: %s\nchild-pid: %s" shell-pid child-pid)
    (if child-pid
        (setq rv (shell-command (format "kill -9 %s" child-pid)))
      ;; (message "No child process to kill!")
      )
    (if rv
        (if (> 0 rv) (message "Process could not be killed: %s" rv)
          ;; (message "Process killed")
          ))))

;; ;; 16000
;; (defun xc/kill-python ()
;;   "Kill Python.
;;
;; Note: This kills indiscriminantly on Windows systems.  It will
;; kill any system process, like the AWS CLI, that runs on the
;; Python interpeter."
;;   (interactive)
;;   (if (eq xc/device 'windows)
;;       (shell-command "taskkill /f /fi \"IMAGENAME eq python.exe\" /fi \"MEMUSAGE gt 15000\"")
;;     (xc/kill-proc-child peut-gerer-current-shell)))


(defun xc/pyside-lookup (&optional arg)
  "Lookup symbol at point in PySide2 online documentation.

Tries to lookup symbol in QWidget documentation.

When called with universal prefix, prompt for module.  This
requires list of modules (provided in `pyside-modules.el').  When
called with negative prefix, search within the online PySide
documentation.

\(fn)"
  (interactive "p")
  (let* ((sym (thing-at-point 'symbol))
         (direct-url (concat
                      "https://doc-snapshots.qt.io/qtforpython-5.15/PySide2/QtWidgets/"
                      sym
                      ".html"
                      ))
         (search-url (concat
                      "https://doc-snapshots.qt.io/qtforpython-5.15/search.html?check_keywords=yes&area=default&q="
                      sym
                      )))
    (cond ((eql arg 1) ; no prefix
           (let ((buff (get-buffer-window "*eww*")))
             (if buff
                 (with-selected-window buff
                   (eww direct-url))
               (eww direct-url))))
          ((eql arg 4)  ; "C-u", expand search to be "universal"
           (let* ((buff (get-buffer-window "*eww*"))
                  (completion-ignore-case t)
                  (module (completing-read "Select module: " xc/pyside-modules nil 'confirm "Qt"))
                  (direct-url (concat
                               "https://doc-snapshots.qt.io/qtforpython-5.15/PySide2/"
                               module "/"
                               (thing-at-point 'symbol)
                               ".html")))
             (if buff
                 (with-selected-window buff
                   (eww direct-url))
               (eww direct-url))))
          ((eql arg -1)  ; "C--", it's 'negative' to have to leave Emacs
           (browse-url-default-browser search-url))
          (t (error "Invalid prefix")))))


(defun xc/occur-definitions ()
  "Display an occur buffer of all definitions in the current buffer.
Also, switch to that buffer.

See URL `https://github.com/jorgenschaefer/elpy/blob/c31cd91325595573c489b92ad58e492a839d2dec/elpy.el#L2556'
"
  (interactive)
  (let ((list-matching-lines-face nil))
    (occur "^\s*\\(\\(async\s\\|\\)def\\|class\\)\s"))
  (let ((window (get-buffer-window "*Occur*")))
    (if window
        (select-window window)
      (switch-to-buffer "*Occur*"))))


(defun xc/jump-to-file-from-python-error ()
  "Jump to line in file specified by a Python traceback or debugger."
  (interactive)
  (let* ((line (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
         file
         number)

    ;; Traceback format:
    ;;   File "C:\projects\my_project\main.py", line 971, in bad_function
    (string-match "^\s+File \\(\"?\\)\\([^,\" \n    <>]+\\)\\1, lines? \\([0-9]+\\)-?\\([0-9]+\\)?" line)

    ;; TODO The following lines cause the function to crash when the
    ;; input doesn't match.  They try to get the 2nd and 3rd match and
    ;; die when they don't exist.  The regex above (and probably
    ;; below) are stolen from the internet and are ill-formated; hence
    ;; grabbing matches 2 and 3.  Match 1 is just the left quote.  Fix
    ;; the regex and then do (match-string 0 line) to see if there was
    ;; a match.  If the regex isn't dumb, then it should return nil
    ;; and we can gracefully let the user know that what they selected
    ;; is not a valid python error line.
    (setq file (match-string 2 line))
    (setq number (match-string 3 line)) ; match is string, not numeric

    (if (not file)
        (progn
          ;; Pdb format:
          ;;   c:\projects\my_project\main.py(971)bad_function()
          (string-match "\\([^,\" \n    <>]+\.py\\)(\\([0-9]+\\))" line)
          (setq file (match-string 1 line))
          (setq number (match-string 2 line))))

    ;; sometimes files are given as relative paths
    (if (not (file-name-absolute-p file))
        (setq file (expand-file-name file peut-gerer-root)))

    (cond ((not (file-exists-p file))
           (message "Could not find file: %s" file))
          ((and file number)
           (find-file-other-window file)
           (with-current-buffer (get-buffer (file-name-nondirectory file))
             (goto-char (point-min))
             (forward-line (1- (string-to-number number))))))))


(defun xc--run-test-emacs-lisp (&optional eval)
  "Run `ert-deftest' test at point.

Optionally EVAL test before running.  Default is to first reload
the test."
  (interactive)
  (let* ((eval (or eval t))
         (current-window (selected-window))
         (defun-string (thing-at-point 'defun t))
         (name (cadr (split-string defun-string)))
         (name-symbol (intern-soft name))
         test)
    (cond ((string-match "ert-deftest" defun-string)
           (if eval (call-interactively #'eval-defun))
           (ert name)
           ;; test struct exists only after test is run
           (setq test (ert-get-test name-symbol))
           (if (eql (aref (ert-test-most-recent-result test) 0) 'ert-test-passed)
               (progn
                 (kill-buffer "*ert*")
                 (select-window current-window))))
          (t (message "No test a point")))))


(defun xc--run-test-python ()
  "Run current Python test.

Either I'm a moron or the Python unittest is a PITA to run just
one test (or both).  It seems you have to declare the test
explicitly, or structure your project in a way that lets you run
the code using an if-main runner.  Or I need to read through
paragraphs of documentation.  I DGAF, I just want to run the test
I'm working on!  Ain't no way I'm going to copy and paste all
that nonsense in. PyTest is a little better–you need to pass in
the test name.

TODO Provide some way to toggle which framework is being used.
As written, you need to (un)comment the relevant format
expression and re-eval the function.

See URL `https://emacs.stackexchange.com/a/19084/'"
  (interactive)
  (let ((test-directory
         (car (last (split-string (file-name-directory (buffer-file-name)) "/" t))))
        (current-module
         (file-name-base (buffer-file-name)))
        (current-class
         (save-excursion
           (end-of-line)
           (search-backward-regexp "^\\s-*\\(?:\\(?:abstract\\|final\\)\\s-+\\)?class\\s-+\\(\\(?:\\sw\\|\\\\\\|\\s_\\)+\\)")
           (match-string 1)))
        (current-test
         (save-excursion
           (python-nav-beginning-of-defun)
           (search-forward "test" (line-end-position))
           (thing-at-point 'symbol t))))
    (if xc/kill-python-p
        (xc/kill-python))
    (xc/send-string
     (format
      ;; "python3 -m unittest %s.%s.%s.%s"
      ;; "python3 -m unittest %s.%s.%s"
      "pytest -x -k '%s'"  ; -x fail on first error, -k run matching pattern
      ;; test-directory  ; unittest
      ;; current-module  ; unittest
      ;; current-class   ; unittest
      current-test    ; unittest/pytest
      )
     nil
     peut-gerer-current-shell)))


(defun xc/run-test ()
  "Run current test based on major mode."
  (interactive)
  (save-some-buffers t nil)
  (cond ((eq major-mode 'python-mode)
         (xc--run-test-python))
        ((eq major-mode 'emacs-lisp-mode)
         (xc--run-test-emacs-lisp))))


(defun xc/statement-to-function (&optional statement func beg end)
  "Convert STATEMENT to FUNC.

For use with statements in Python such as 'print'.  Converts
statements like,

  print \"Hello, world!\"

to a function like,

  print(\"Hello, world\")

Also works generally so that the STATEMENT can be changed to any
FUNC.  For instance, a 'print' statement,

  print \"Hello, world!\"

could be changed to a function,

  banana(\"Hello, world!\")

Default STATEMENT is 'print'.  Default FUNC is
STATEMENT (e.g. 'print').  Prompt for STATEMENT and FUNC when
called with universal prefix, `C-u'.

If region is selected interactively, only perform conversion
within the region.  The same can be achieved programmatically
using BEG and END of the desired region."
  (interactive "p")
  (let* ((arg statement)  ; statement argument overwritten, so preserve value
         ;; only prompt on universal prefix; 1 means no universal, 4 means universal
         (statement (cond ((eql arg 1) "print")  ; no prefix
                          ((eql arg 4) (read-string "Statement (print): " "" nil "print")))) ; C-u
         (func (cond ((eql arg 1) statement)  ; no prefix
                     ((eql arg 4) (read-string (concat "Function " "(" statement "): ") "" nil statement)))) ; C-u
         ;; [[:space:]]*  -- allow 0 or more spaces
         ;; \\(\"\\|\'\\) -- match single or double quotes
         ;; \\(\\)        -- define capture group for statement expression; recalled with \\2
         (regexp (concat statement "[[:space:]]*\\(\"\\|\'\\)\\(.*?\\)\\(\"\\|'\\)"))
         ;; replace statement with function and place statement expression within parentheses \(\)
         (replace (concat func "\(\"\\2\"\)"))
         ;; set start of replacement region to what the user passed in
         ;; (if used programmatically), beginning of region (if used
         ;; interactively with a region selected), or the start of the
         ;; buffer (if no region specified)
         (beg (or beg (if (use-region-p) (region-beginning)) (point-min)))
         ;; end defines the `bound' of the regexp search. According to
         ;; documentation, "the match found must not end after this."
         ;; Extend the end of the region slightly to compensate.
         ;; While this may technically introduce an unwanted match, it
         ;; is unlikely for any but the shortest statements (probably
         ;; less than 2 or 3 characters).  Doing this at the end of a
         ;; buffer sometimes results in a "while: Invalid search bound
         ;; (wrong side of point)" error.  It may be an Emacs
         ;; bug. Regardless, it does not appear to affect the results
         ;; which are otherwise as expected. A value of nil means
         ;; search to the end of the accessible portion of the buffer.
         (end (or end (if (use-region-p) (+ (region-end) 3) nil))))
    (save-excursion
      (goto-char beg)
      (while (re-search-forward regexp end t)
        (replace-match replace nil t)))))


(defun xc/venv-activate ()
  "Activate venv."
  (interactive)
  (insert "venv\\Scripts\\activate"))


(defun xc/venv-create ()
  "Create Python venv.

I don't keep Python on my path.  Unfortunately, the autocomplete
in shell.el pulls completions from other buffers, creating a
chicken and egg problem."
  (interactive)
  (insert "\"C:\\python\\python37\\python.exe\" -m venv venv"))

;; https://stackoverflow.com/a/6200347/5065796
(setq xc/debugger-client-port 4444)
(setq xc/debugger-client-host "127.0.0.1")

(defun xc/start-debugger-client nil
  (interactive)
  (make-network-process
   :name "xc/debugger-client"
   :buffer "*xc/debugger-client*"
   :family 'ipv4
   :host xc/debugger-client-host
   :service xc/debugger-client-port
   :sentinel 'xc--debugger-client-sentinel
   :filter 'xc--debugger-client-filter)

  (switch-to-buffer "*xc/debugger-client*")

  (with-current-buffer "*xc/debugger-client*"
    (comint-mode)
    (setq-local comint-prompt-regexp "\\((MyDebugger) \\|>>> \\|In \\[[[:digit:]]\\]: \\)")
    (setq-local comint-use-prompt-regexp t)))

(defun xc/stop-debugger-client nil
  (interactive)
  (delete-process "xc/debugger-client"))

(defun xc--debugger-client-filter (proc string)
  (comint-output-filter proc string))

(defun xc--debugger-client-sentinel (proc msg)
  (when (string= msg "connection broken by remote peer\n")
    (with-current-buffer "*xc/debugger-client*"
      (insert (format "client %s has quit" proc))
      (bury-buffer))))

(defun xc/qt-live-code ()
  "Call ipython interactively with live-code toggle."
  (interactive)
  (insert "ipython -i -- qt_live_code.py live"))

(defun xc/run-python-with-qt-live-code ()
  (interactive)
  (let ((current-prefix-arg '(4))
        (python-shell-interpreter-args "-i -- qt_live_code.py live"))
    (call-interactively 'run-python )))

(defun xc/toggle-build-debug ()
  (interactive)
  (insert "set BUILD_DEBUG="))

(defun xc/kill-qgis ()
  (interactive)
  ;; (shell-command "taskkill /f /fi \"IMAGENAME eq qgis-ltr-bin.exe\""))
  (shell-command "taskkill /f /fi \"IMAGENAME eq qgis-bin.exe\""))

(defun xc/run-qgis ()
  (interactive)
  (save-some-buffers t nil)
  (xc/kill-qgis)
  (shell-command "taskkill /f /t /fi \"WINDOWTITLE eq \\qgis\\ \"")
  ;; (let ((proc (start-process "cmd" nil "cmd.exe" "/C" "start" "\"qgis\"" "cmd.exe" "/K" "C:\\Program Files\\QGIS 3.10\\bin\\qgis-ltr.bat")))
  (let ((proc (start-process "cmd" nil "cmd.exe" "/C" "start" "\"qgis\"" "cmd.exe" "/K" "C:\\Program Files\\QGIS 3.22.3\\bin\\qgis.bat")))
    (set-process-query-on-exit-flag proc nil))
  ;; assume qgis loads in X seconds
  (run-at-time "3 sec" nil #'(lambda () (progn (shell-command "taskkill /f /fi \"WINDOWTITLE eq \\qgis\\ \"")))))


(defun xc/spam-filter (string)
  "Filter stupid comint spam."
  (with-current-buffer (current-buffer)
    (mark-whole-buffer)
    (flush-lines "/home/ahab/Projects/scratch/plover/stubs/plover/")))
;; (flush-lines "QTextCursor::setPosition: Position '[0-9]+' out of range")))
;; (flush-lines "has no notify signal and is not constant")))


(defun xc/toggle-spam-filter ()
  "Toggle spam filter"
  (interactive)
  (if (member 'xc/spam-filter comint-output-filter-functions)
      (progn
        (setq comint-output-filter-functions
              (delete 'xc/spam-filter comint-output-filter-functions))
        (message "Spam filter off"))
    (progn
      (add-hook 'comint-output-filter-functions 'xc/spam-filter)
      (message "Spam filter on"))))


(defun xc/-append-newline-after-comma (x)
  (replace-regexp-in-string "," ",\n" x))

(defun xc/toggle-long-line-filter ()
  "Prevent long lines from bogging down the shell."
  (interactive)
  (if (member 'xc/-append-newline-after-comma comint-preoutput-filter-functions)
      (progn
        (remove-hook 'comint-preoutput-filter-functions 'xc/-append-newline-after-comma t)
        (message "Removed local long line filter"))
    (progn
      (add-hook 'comint-preoutput-filter-functions 'xc/-append-newline-after-comma 0 t)
      (message "Added local long line filter"))))

;; (remove-hook 'comint-preoutput-filter-functions 'xc/-append-newline-after-comma)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; extensions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun xc/hex-quiz ()
  "Practice your hex addition."
  (interactive)
  (let ((total 0.0)
        (correct 0))
    (condition-case err
        (while t
          (let* ((number1 (random 16))
                 (number2 (random 16))
                 (answer (+ number1 number2))
                 (reply  (string-to-number (read-string (format "x%02X + x%02X = x" number1 number2)) 16)))
            (setq total (1+ total))
            (if (= reply answer)
                (progn
                  (setq correct (1+ correct))
                  (message (format "x%02X + x%02X = x%02X Correct!" number1 number2 answer)))
              (message (format "x%02X + x%02X = x%02X Not x%02X!" number1 number2 answer reply)))
            (sleep-for 0 650)))
      (quit
       (message "You got %%%d correct (%d of %d)." (* (/ correct total) 100) correct total)))))

(defun xc/int-to-binary-string2 (&optional arg int)
  "Convert INT into a binary string.

Modified from: `https://stackoverflow.com/a/27156006'

NOTE: Conversion may be incorrect.  I did not verify.  Also, the
args are dumb."
  (interactive "p\nnConvert to binary: ")
  (let ((res "")
        (cnt 1))
    (while (not (= int 0))
      (setq res (concat (if (= 1 (logand int 1)) "1" "0") res))
      (setq int (lsh int -1))
      ;; (if (= cnt 3)
      (if (= (% cnt 4) 0)
          (setq res (concat " " res)))
      (setq cnt (+ cnt 1)))
    (if (string= res "")
        (setq res "0"))
    (cond ((= arg 1)
           (message "%s" res))
          (t (insert res)))))

(defun xc/-int-to-binary-string (int &optional precision)
  "Convert INT into a binary string with PRECISION.

Convert to decimal using:

  (string-to-number (xc/-int-to-binary-string 10) 2)

See URL `https://stackoverflow.com/a/20577329'"
  (let* ((precision (or precision 4))
         (fstring (concat "%0" (number-to-string precision) "d"))
         (res ""))
    ;; peel off powers of 2
    ;; if even, record a 1 and shift right (i.e. divide by 2)
    (while (not (= int 0))
      (setq res (concat (if (= 1 (logand int 1)) "1" "0") res))
      (setq int (ash int -1)))
    (if (string= res "")
        (setq res "0000"))
    ;; this next part cheats. Convert to decimal so that it can be
    ;; padded left with zeroes.  It's all strings, so who cares if it
    ;; gets converted temporarily to decimal?  :)
    (format fstring (string-to-number res))))

(defun xc/binary-quiz ()
  "Practice your hex to binary conversion.

Hint: Convert numbers x0-x9 immediately. For xA-xF, convert to
decimal first by putting a 1 in the ten's place and then taking
the alphabet number less 1 for the one's place.  Convert the
resulting decimal.  For example, xE is the fifth letter of the
alphabet. 5-1=4 so that xE is 14.  14 is then 1110."
  (interactive)
  (let ((total 0.0)
        (correct 0))
    (condition-case err
        (while t
          (let* ((answer (random 16))
                 (answer-in-binary (xc/-int-to-binary-string answer))
                 (raw-reply (read-string (format "x%02X = b" answer)))
                 (reply (string-to-number raw-reply 2)))
            (setq total (1+ total))
            (if (= reply answer)
                (progn
                  (setq correct (1+ correct))
                  (message (format "x%02X = b%s Correct!" answer answer-in-binary)))
              (message (format "x%02X = b%s Not b%s!" answer answer-in-binary (xc/-int-to-binary-string reply))))
            (sleep-for 1)))
      (quit
       (message "You got %%%d correct (%d of %d)." (* (/ correct total) 100) correct total)))))

(defun xc/build-tags (dir &optional exclude file)
  "Create tags FILE for DIR, excluding files and directories
matching patterns listed in EXCLUDE.

When used interactively, EXCLUDE patterns are prompted for until
nothing is entered. FILE name defaults to \"TAGS\".  If FILE
successfully created, user is prompted to (re)visit the tags
table specified by FILE.

When called from lisp, FILE is optional, defaulting to \"TAGS\"
located in DIR.  Use `expand-file-name' when passing FILE for
best results."
  (interactive (let* ((dir (read-directory-name "Directory: " nil nil t))
                      (exclude))
                 (setq exclude
                       (butlast  ; trim "" inserted on final user input
                        (cl-loop collect
                                 (read-regexp
                                  (format (if regexps "Exclude regex (%s): " "Exclude regex: ") regexps))
                                 into regexps
                                 finally return regexps
                                 while (not (string= "" (car (last regexps)))))))
                 (list dir exclude nil)))
  (let* ((target
          (if (not (file-directory-p dir))
              (error "Invalid directory: '%s'" dir)
            ;; ctags doesn't generate tags if target file is a
            ;; directory (ends in slash)
            (directory-file-name dir)))
         ;; https://stackoverflow.com/a/25819720
         (exclusion-args (cl-loop for e in exclude concat (format "--exclude=%s " e)))
         (tags-file (or file (concat (file-name-as-directory target) "TAGS")))
         (tags-revert-without-query t))

    ;; needed to notify user that new tags were generated
    (if (file-exists-p tags-file)
        (delete-file tags-file t))

    (if (eq xc/device 'gnu)
        (progn
          (message "Taking longer because of a stupid hack to look up the correct ctags program...")
          (shell-command
           (format "%s/bin/ctags -f %s -eR %s %s"
                                        ; grep package listing for latest universal-ctags location in store
                   (string-trim-right (shell-command-to-string "guix package -l | grep \"universal-ctags\" | sort -r | head -n 1 | cut -f 4"))
                   tags-file
                   exclusion-args
                   target)))
      (shell-command (format "ctags -f %s -eR %s %s" tags-file exclusion-args target)))

    (if (file-exists-p tags-file)
        (if (y-or-n-p (format "Built \"%s\".  Visit? " tags-file))
            (progn
              ;; (setq tags-file-name nil)
              (visit-tags-table tags-file))))))


(defun xc/surround (&optional open close beg end)
  "Surround each line within BEG and END between OPEN and CLOSE.

OPEN and CLOSE are double-quotes by default."
  ;; TODO make work on single line; currently the current line and the
  ;; next must be selected
  (interactive)
  (let* ((open (or open "\""))
         (close (or close "\""))
         (beg (or beg (if (use-region-p) (region-beginning))))
         (end (or end (if (use-region-p) (region-end))))
         (text (if (and beg end) (buffer-substring-no-properties beg end)))
         lines)
    (when (and text (or (string-match "\n" text)))
      (setq lines (butlast (split-string text "\n")))
      (delete-region beg end)
      (cl-loop for line in lines
               do
               (insert (format "%s%s%s\n" open line close))))))

(global-set-key (kbd "M-[") 'backward-paragraph)
(global-set-key (kbd "M-]") 'forward-paragraph)
(global-set-key (kbd "M-v") 'other-window)
(global-set-key (kbd "C-M-j") '(lambda () (interactive) (occur (thing-at-point 'symbol 't))))
(global-set-key (kbd "C-j") 'occur)

(global-set-key (kbd "<f9>") 'save-buffer)
(global-set-key (kbd "C-x s") 'save-buffer)
(global-set-key (kbd "C-a") 'xc/smart-beginning-of-line)
(global-set-key (kbd "M-l") 'xc/recenter-window-top-bottom)
(global-set-key (kbd "M-c") 'xc/copy-symbol-at-point)
(global-set-key (kbd "C-h g") 'shortdoc-display-group)  ; also remember C-h d for apropos-documentation
(global-set-key (kbd "C-=") 'iedit-mode)
(global-set-key (kbd "C-M-S-t") 'swap-regions)
(global-set-key (kbd "C-h j") 'describe-face)
(global-set-key (kbd "C-S-v") 'set-mark-command)

;; (global-set-key (kbd "C-x i i") '(lambda () (interactive) (find-file "~/.emacs.d/init.el"))

(global-set-key (kbd "C-;") '(lambda () (interactive) (if (and (eq major-mode 'org-mode) (eq (org-in-src-block-p) t))
                                          (call-interactively 'org-comment-dwim-2)
                                        (call-interactively 'comment-dwim-2))))

(tool-bar-add-item "separator" nil 'separator1)

(tool-bar-add-item "spell"
             'eval-last-sexp
             'eval-last-sexp
             :help "Eval last sexp")

(tool-bar-add-item "separator" nil 'separator2)

(tool-bar-add-item "back-arrow"
             'org-tree-slide-move-previous-tree
             'org-tree-slide-move-previous-tree
             :help "Previous slide")

(tool-bar-add-item "fwd-arrow"
             'org-tree-slide-move-next-tree
             'org-tree-slide-move-next-tree
             :help "Next slide")

(tool-bar-add-item "up-arrow"
             'previous-line-or-history-element
             'up
             :help "Up")

;; remove redundent toolbar items
(tool-bar-add-item-from-menu 'find-file "")
(tool-bar-add-item-from-menu 'menu-find-file-existing "")
(tool-bar-add-item-from-menu 'dired "")




;; end init.el
(message "Loaded init.el")
