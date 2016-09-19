;;; handy-functions --- a collection of functions I'm too lazy to organize properly...
;;; Commentary:
;;
;;  A collection of miscellaneous functions, which are either
;;  candidates to migrate to a minor mode, or will languish here in
;;  perpetuity.
;;
;;  Sorted in no particular order.
;;
;;; License:
;;  GPL3
;;
;;; Commentary:
;;
;; Some handy functions, homemade, pilfered, re-jigged, squeezed,
;; shuffled... do what thou wilt.
;;
;; Global keys ...
;;
;; - C-S-o    open-line-above
;; - C-o      open-line-below
;; - C-a      smart-beginning-of-line
;; - C-c R    pcre-regexp-from-list-of-words
;; - ESC M-d  kill-whole-word
;; - ESC M-p  describe-thing-in-popup (just does emacs lisp functions and variables)
;; - C-c M-+  increase-default-font-height
;; - C-c M--  decrease-default-font-height
;; - C-c =    set-default-font-height
;;
;;; Code:

(require 's)
(require 'dash)
(require 'find-func)
(require 'popup)

(defun clear-buffer-text-properties ()
    "Clear all text face properties in the buffer.
This is somewhat useful when dealing with text pasted from a
propertied buffer.

Note: this won't turn off face properties in a font-locked buffer."
    (interactive)
    (remove-text-properties 1 (point-max) '(face nil)))

(defun nuke-all-buffers ()
  "Kill all buffers, leaving *scratch* only."
  (interactive)
  (mapc
   (lambda (buffer)
     (kill-buffer buffer))
   (buffer-list))
  (delete-other-windows))

(defun nuke-all-buffers-execept-current ()
  "Kill all the open buffers except the current one.
Leave *scratch* and *Messages* alone too."
  (interactive)
  (mapc
   (lambda (buffer)
     (unless (or
              (eq (current-buffer) buffer)
              (string= (buffer-name buffer) "*scratch*")
              (string= (buffer-name buffer) "*Messages*"))
       (kill-buffer buffer)))
   (buffer-list))
  (delete-other-windows))

(defun -sample (list)
  "Return a random element from the LIST."
    (nth (random (length list)) list))

(defun insert-sample (strings)
  "Insert a random item from a list of STRINGS."
  (interactive "sList of strings separated by spaces: ")
  (insert (-sample (s-split " " strings))))

(defvar saved-mode-line
  nil
  "Save register for mode-line.")

(defun toggle-mode-line-on-off ()
  "Toggle the modeline off and on.
Uses `saved-mode-line' as a register.

Note this only affects the current buffer,
and it doesn't seem to work wth key bindings."
  (interactive)
  (if (eq mode-line-format nil)
      (setq mode-line-format saved-mode-line)
    (progn
      (setq saved-mode-line mode-line-format)
      (setq mode-line-format nil))))

(defun join-line-from-below ()
  "Join line from below."
  (interactive)
  (forward-line 1)
  (delete-indentation))

(defun prepend-existing-to-exec-path (path)
  "If PATH exists, prepend it to `exec-path'."
  (when (file-exists-p path)
    (setq exec-path (append '(path) exec-path))))

(defun align-number-right (begin end)
  "Align region to equal signs from BEGIN to END."
  (interactive "r")
  (align-regexp begin end ".* \\([0-9]+\\).*" -1 1 nil))

(defun insert-random-in-range (start end)
  "Insert a random number within the range of START and END."
  (interactive "nRange start:\nnRange end:")
  (insert (format "%i" (random-in-range start end))))

(defun insert-random-radian ()
  "Insert a radian value from 0 to 6.28318 (2PI : 360 deg)."
  (interactive)
  (insert (format "%s" (* (/ float-pi 180) (random 361)))))

(defun fraction-radian (denominator)
  "Fraction DENOMINATOR of circle to radians."
  (interactive "nDenomiator:")
  (insert (format "%s" (/ (* float-pi 2) denominator))))

(defun random-in-range (start end)
  "Return a random number in range START to END."
  (random t)
  (+ start (random (+ 1 (- end start)))))

(defun now-is ()
  "Insert current time."
  (interactive)
  (insert (format-time-string "%l:%M%P(%z) %Y-%m-%d")))

(defun utc-seconds ()
  "Insert UTC seconds."
  (interactive)
  (insert (format-time-string "%s")))

(defun untabify-buffer ()
  "Untabify the current buffer."
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  "Indent the current buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a cleanup operations on a buffer, tabs to spaces, re-indent, trim whitespace."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))

(defun toggle-window-split ()
  "Toggle the current window split."
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

(defun open-line-below ()
  "Open a newline below the current point."
  (interactive)
  (end-of-line)
  (newline)
  (back-to-indentation))

(defun open-line-above ()
  "Open a newline above the current point."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (newline)
    (forward-line -1)))

;; Originally swiped from rejeep's emacs.d rejeep-defuns.el.
(defun duplicate-current-line-or-region (arg)
  "Duplicates the current line or region ARG times."
  (interactive "p")
  (let (beg end (origin (point)))
    (if (and (region-active-p) (> (point) (mark)))
        (exchange-point-and-mark))
    (setq beg (line-beginning-position))
    (if (region-active-p)
        (exchange-point-and-mark))
    (setq end (line-end-position))
    (let ((region (buffer-substring-no-properties beg end)))
      (dotimes (i arg)
        (goto-char end)
        (newline)
        (insert region)
        (setq end (point)))
      (goto-char (+ origin (* (length region) arg) arg)))))

(defun shell-command-on-region-replace (start end command)
  "Run `shell-command-on-region' replacing the selected region.  START END COMMAND."
  (interactive (let (string)
                 (unless (mark)
                   (error "The mark is not set now, so there is no region"))
                 (setq string (read-from-minibuffer "Shell region | replace: "
                                                    nil nil nil
                                                    'shell-command-history))
                 (list (region-beginning) (region-end)
                       string)))
  (shell-command-on-region start end command t t))

(defun directory-of-library (libraryname)
  "Open directory with dired which contain the given LIBRARYNAME."
  (interactive "M")
  (dired (file-name-as-directory
          (file-name-directory (find-library-name libraryname)))))

(defun join-line-or-lines-in-region ()
  "Join this line or the lines in the selected region."
  (interactive)
  (cond ((region-active-p)
         (let ((min (line-number-at-pos (region-beginning))))
           (goto-char (region-end))
           (while (> (line-number-at-pos) min)
             (join-line))))
        (t (call-interactively 'join-line))))

(defun comment-or-uncomment-current-line-or-region ()
  "Comments or uncomments current current line or whole lines in region."
  (interactive)
  (save-excursion
    (let (min max)
      (if (region-active-p)
          (setq min (region-beginning) max (region-end))
        (setq min (point) max (point)))
      (comment-or-uncomment-region
       (progn (goto-char min) (line-beginning-position))
       (progn (goto-char max) (line-end-position))))))

(defun rename-this-buffer-and-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name))
        (read-file-name-function 'read-file-name-default))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (cond ((get-buffer new-name)
               (error "A buffer named '%s' already exists!" new-name))
              (t
               (rename-file filename new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil)
               (message "File '%s' successfully renamed to '%s'" name (file-name-nondirectory new-name))))))))

(defun delete-this-buffer-and-file (force)
  "Delete the file connected to this buffer and kill it, FORCE is universal argument."
  (interactive "P")
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "'%s' is not a file buffer" name)
      (when (or force (yes-or-no-p (format  "Delete '%s', Are you sure? " filename)))
        (delete-file filename)
        (kill-buffer buffer)
        (message "Deleted '%s'" filename)))))

(defun switch-to-scratch ()
  "Switch to scratch, grab the region if it's active."
  (interactive)
  (let ((contents
         (and (region-active-p)
              (buffer-substring (region-beginning)
                                (region-end)))))
    (switch-to-buffer "*scratch*")
    (if contents
        (progn
          (goto-char (buffer-end 1))
          (insert contents)))))

(defun eval-and-replace-prin1 ()
  "Replace the preceding sexp with its value using prin1."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(defun eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (insert (format "%s" (eval (read (current-kill 0)))))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(defmacro *-and-replace (function-name evaluator)
  "Build FUNCTION-NAME to use EVALUATOR on the current region, and replace it with the result."
  `(defun ,function-name ()
     (interactive)
     (when (region-active-p)
       (let* ((input (buffer-substring-no-properties (region-beginning) (region-end)))
              (output (funcall ,evaluator input)))
         (delete-region (region-beginning) (region-end))
         (insert (if (stringp output) output
                   (format "%S" output)))))))

(*-and-replace calc-eval-region #'calc-eval)

(require 'magit)
(defun magit-just-amend ()
  "Just git commit --amend."
  (interactive)
  (save-window-excursion
    (shell-command "git --no-pager commit --amend --reuse-message=HEAD")
    (magit-refresh)))

(defun shell-command-on-buffer-file ()
  "Run a shell command, using the file of current buffer as input.
Return an error if no buffer file."
  (interactive)
  (or (buffer-file-name) (error "There is no file associated with this buffer"))
  (let* ((my-cmd (read-shell-command "Command to run: "))
         (cmd-to-run (concat my-cmd " " (buffer-file-name))))
    (shell-command cmd-to-run)))

(defun snake-case-at-point-or-region ()
  "Snake_case the current word or text selection."
  (interactive)
  (operate-on-point-or-region 's-snake-case))

(defun dasherise-at-point-or-region ()
  "Dasherise-the-current CamelCase or snake_case word or text selection."
  (interactive)
  (operate-on-point-or-region 's-dashed-words))

(defun upper-camelcase-at-point-or-region ()
  "UpperCamelCaseTheCurrent dashed-or-snake_case_words or any words in text selection."
  (interactive)
  (operate-on-point-or-region 's-upper-camel-case))

(defun lower-camelcase-at-point-or-region ()
  "LowerCamelCaseTheCurrent dashed or snake_case word or any words in text selection."
  (interactive)
  (operate-on-point-or-region 's-lower-camel-case))

(defun humanize-at-point-or-region ()
  "Humanize variable names, insert spaces instead of - or _ or un-CamelCase humps to spaced words."
  (interactive)
  (operate-on-point-or-region 's-capitalized-words))

(defun titleized-at-point-or-region ()
  "Convert snaked, dashed, underscored, camelcase, or spaced words in region to Title Case."
  (interactive)
  (operate-on-point-or-region 's-titleized-words))

(defun url-encode-string-at-point ()
  "URL Encode the current string at point."
  (interactive)
  (operate-on-point-or-region 'url-encode-url))

(defun operate-on-point-or-region (fn)
  "Get the current unspaced string at point.
Replace with the return value of the function FN"
  (let (pos1 pos2 meat excerpt)
    (if (and transient-mark-mode mark-active)
        (setq pos1 (region-beginning)
              pos2 (region-end))
      (setq pos1 (car (bounds-of-thing-at-point 'symbol))
            pos2 (cdr (bounds-of-thing-at-point 'symbol))))
    (setq excerpt (buffer-substring-no-properties pos1 pos2))
    (setq meat (funcall fn excerpt))
    (delete-region pos1 pos2)
    (insert  meat)))

(defun yank-repeat (&optional arg)
  "Repeat yank n times ARG."
  (interactive "*p")
  (dotimes (string-to-int arg) (yank)))

(defun smart-beginning-of-line ()
  "Move point to first non-whitespace character or `beginning-of-line'."
  (interactive)
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
         (beginning-of-line))))

(defun pretty-print-xml-region (begin end)
  "Pretty format XML markup in region BEGIN END."
  (interactive "r")
  (save-excursion
    ;; split <foo><bar> or </foo><bar>, but not <foo></foo>
    (goto-char begin)
    (while (search-forward-regexp ">[ \t]*<[^/]" end t)
      (backward-char 2) (insert "\n") (incf end))
    ;; split <foo/></foo> and </foo></foo>
    (goto-char begin)
    (while (search-forward-regexp "<.*?/.*?>[ \t]*<" end t)
      (backward-char) (insert "\n") (incf end))
    ;; put xml namespace decls on newline
    (goto-char begin)
    (while (search-forward-regexp "\\(<\\([a-zA-Z][-:A-Za-z0-9]*\\)\\|['\"]\\) \\(xmlns[=:]\\)" end t)
      (goto-char (match-end 0))
      (backward-char 6) (insert "\n") (incf end))
    (indent-region begin end nil)))

(defun toggle-fullscreen ()
  "Toggle full screen."
  (interactive)
  (when window-system
    (set-frame-parameter
     nil 'fullscreen
     (when (not (frame-parameter nil 'fullscreen)) 'fullboth)) ))

(defun copy-region-to-osx-clipboard ()
  "Copy contents of the current region to the OS X Clipboard."
  (interactive)
  (shell-command-on-region
   (region-beginning)
   (region-end)
   "pbcopy"))

(defun copy-buffer-to-osx-clipboard ()
  "Copy contents of the current buffer to the OS X Clipboard."
  (interactive)
  (shell-command-on-region
   (point-min)
   (point-max)
   "pbcopy"))

(defun search-backward-wrapped-string (wrap_start wrap_end)
  "Search for a string backwards from the current point.

Use the strings WRAP_START and WRAP_END, to match the start and
end of the string.

if WRAP_END and WRAP_START are equal, we first position the point
at the beginning of the first WRAP_END match, before the initial
point.

The string found between the two wrappers is returned.

This is useful for naive finding of symbols previously defined in
the buffer."
  (save-excursion
    (when (equal wrap_start wrap_end)
      (search-backward wrap_end))
    (let* ((start_match
            (+ (search-backward wrap_start)
               (length wrap_start)))
           (end_match 0))
      (goto-char start_match)
      (setq end_match (- (search-forward wrap_end) 1))
      (buffer-substring-no-properties start_match end_match))))

(defun pcre-regexp-from-list-of-words (words)
  "Insert a pcre regexp to match a list of WORDS."
  (interactive "sList of words for regexp: ")
  (insert
   (pcre-to-elisp
    (regexp-opt (split-string words)))))

(defun kill-whole-word ()
  "Kill the current word at point."
  (interactive)
  (backward-word)
  (kill-word 1))

(defun sass-hex-color-to-var ()
  "Find a hex color, and replace it with a newly created variable name.
Place the created variable at the top of the file.  Name it based
on the property being set, and its CSS selector, and set its
css-value to the hex color found."
  (interactive)
  (let
      (css-value
       css-property
       css-value-position
       variable-name
       variable-definition
       indent-level
       (css-selector ""))
    (save-excursion
      ;; search for a hex color
      (re-search-forward
       (rx bol (0+ blank)
           ;; CSS Property name
           (group (? "-") (regex "[_A-z]") (1+ (regex "[_0-9A-z-]")))
           (* blank) ":" (* blank) (* (regex "[A-z,0-9.% ]"))
           ;; Hex color
           (group "#" (** 3 6 (any hex-digit))) ";" eol))

      (setq css-value-position (match-beginning 2))
      (setq css-property (match-string-no-properties 1))
      (setq css-value  (match-string-no-properties 2))

      (move-end-of-line 1)
      (back-to-indentation)
      (setq indent-level (current-column))
      (while (< 0 indent-level)
        (re-search-backward
         (rx bol (* blank) (? "&") (? (any "." "#"))
             (group (any "_" alpha) (* (any "_" "-" "," " " ":" alphanumeric)))
             (* blank) "{"))
        (move-end-of-line 1)
        (back-to-indentation)
        (when (> indent-level (current-column))
          (setq indent-level (current-column))
          (setq css-selector
                (format "%s_%s" (match-string-no-properties 1) css-selector))))

      (setq variable-name
            (replace-regexp-in-string
             (rx (>= 2 "_")) "_"
             (replace-regexp-in-string
              (rx (any "&" ":" "-" "," " "))
              "_"
              (format "$%s%s" css-selector css-property))))

      (setq variable-definition (format "%s: %s;" variable-name css-value)))
    (goto-char css-value-position)

    (re-search-forward
     (rx "#" (** 3 6 (any hex-digit)) (0+ blank) ";" ))
    (replace-match (format "%s;" variable-name) t)

    (goto-char 0) (newline) (goto-char 0)
    (insert variable-definition)))

(defun markdown-codefence-region (start end)
  "Enclose the region (START END) in a GFM code-fence, ie. enclosed in three backticks."
  (interactive "r")
  (if (and start end)
      (progn
        (goto-char end)
        (insert "\n```\n\n")
        (delete-blank-lines) ; keep only a single blank line below
        (goto-char start)
        (insert "\n\n```\n")
        (forward-line -2)
        (delete-blank-lines) ; keep only a single blank line above
        (goto-char end)
        (forward-line))
    (message "markdown-codefence-region requires a region")))

;; TODO Make a Emacs interface to chrome-cli instead.
(defun reload-current-chrome-tab-osx ()
  "Run a simple applescript to reload the current Google Chrome tab.

OSX specific of course."
  (interactive)
  (shell-command "echo 'tell application \"Google Chrome\"
                             reload active tab of window 1
                        end tell' | osascript" nil nil)
  (message "refreshed active Google Chrome tab"))

(defun open-opsmanager ()
  "Open OpsManager in dired."
  (interactive)
  (find-file "~/workspace/OpsManager"))

(defun get-osx-display-resolution ()
  "Get the current display resolution in OSX."
  (--map (s-split "x" it)
         (--filter (not (string= it ""))
                   (s-split "\n" (shell-command-to-string
                                  "system_profiler SPDisplaysDataType |\
                                   grep Resolution |\
                                   sed -e 's/Resolution: //' -e 's/ //g'")))))

(defun increase-default-font-height (m)
  "Adjust the default font :height by 10, universal argument is M (to set by multiples)."
  (interactive "p")
  (let ((new-height (+ (* m 10) (face-attribute 'default :height))))
    (set-face-attribute 'default nil :height new-height)
    (message "Default font height set to %i" new-height)))

(defun decrease-default-font-height (m)
  "Adjust the default font :height by 10, universal argument is M (to set by multiples)."
  (interactive "p")
  (increase-default-font-height -1))

(defun set-default-font-height (p)
  "Set the default font :height P (prefix arg) or enter in minibuffer."
  (interactive "P")
  (unless p
    (setq p (string-to-number (read-from-minibuffer
                               (format "Set default font height (currently %s): "
                                       (face-attribute 'default :height))))))
  (set-face-attribute 'default nil :height  p)
  (message "Default font height set to %s" p))

(defun set-pivotal-api-key-from-dotfile ()
  "Set the `pivotal-api-token' from the setting in ~/.pivotal_api_key if it exists."
  (interactive)
  (if (file-exists-p "~/.pivotal_api_key")
      (progn
        (setq pivotal-api-token
              (substring-no-properties
               (with-temp-buffer
                 (insert-file-contents "~/.pivotal_api_key")
                 (buffer-string)) 5 37))
        (message "Pivotal api token was set to: %S" pivotal-api-token))
    (message "~/.pivotal_api_key was not found")))

;; Quick helpers to describe function or variable at point in help or popup
(defun describe-thing-at-point ()
  (interactive)
  (let* ((thing (symbol-at-point)))
    (cond
     ((fboundp thing) (describe-function thing))
     ((boundp thing) (describe-variable thing)))))

(defun describe-thing-in-popup ()
  (interactive)
  (let* ((thing (symbol-at-point)))
    (cond
     ((fboundp thing) (describe-in-popup 'describe-function))
     ((boundp thing) (describe-in-popup 'describe-variable)))))

(defun describe-variable-in-popup ()
  (interactive)
  (describe-in-popup 'describe-variable))

(defun describe-function-in-popup ()
  (interactive)
  (describe-in-popup 'describe-function))

(require 'pos-tip)
(require 'popup)
(defun describe-in-popup (fn)
  "Open a postip containing the help text of `symbol-at-point' using FN.

FN should be either `describe-variable' or `describe-function'."
  (let* ((thing (symbol-at-point))
         (description
          (replace-regexp-in-string
           "\\[BACK\\]" ""
           (save-window-excursion
             (funcall fn thing)
             (switch-to-buffer "*Help*")
             (buffer-string)))))
    (pos-tip-show description 'popup-tip-face nil nil -1)))

(defun describe-at-cursor-position-in-popup ()
  "Open a popup containing detailed info about the current cursor position."
  (interactive)
  (pos-tip-show (replace-regexp-in-string
                 "\\[BACK\\]" ""
                 (save-window-excursion
                   (what-cursor-position t)
                   (switch-to-buffer "*Help*")
                   (buffer-string)))
                'popup-tip-face nil nil -1))

(defun zap-to-string (&optional arg)
  "Zap text up to a string, ARG can be minus to zap backwards."
  (interactive "p")
  (let ((text (read-from-minibuffer "Zap to string: ")))
    (kill-region (point) (progn
                           (search-forward text nil nil arg)
                           (point)))))

(defun zap-to-regexp (&optional arg)
  "Zap text up to a regexp, ARG can be minus to zap backwards."
  (interactive "p")
  (let ((regexp (read-from-minibuffer "Zap to regexp: ")))
    (kill-region (point) (progn
                           (re-search-forward regexp nil nil arg)
                           (point)))))

;; Key bindings
(defun zap-up-to-string (&optional arg)
  "Zap text up to a string, ARG can be minus to zap backwards."
  (interactive "p")
  (let ((text (read-from-minibuffer "Zap up to string: ")))
    (kill-region (point) (progn
                           (search-forward text nil nil arg)
                           (backward-char (* arg (length text)))
                           (point)))))

(defun zap-up-to-regexp (&optional arg)
  "Zap text up to a regexp, ARG can be minus to zap backwards."
  (interactive "p")
  (let
      ((regexp (read-from-minibuffer "Zap up to regexp: ")))
    (kill-region (point) (progn
                           (re-search-forward regexp nil nil arg)
                           (re-search-backward regexp nil nil arg)
                           (point)))))

(defun make-kurecolor-hue-table ()
  "Make a hue table from hex color at top of kill ring, no error checking."
  (interactive)
  (let ((color (car kill-ring-yank-pointer)))
    (loop for (a b) in '((1 12) (13 24) (25 36))
          do
          (insert ";; ")
          (loop for i from a upto b do
                (insert (format "%-4s    " (format "%s°" (* i 10)))))
          (newline-and-indent)
          (insert ";;")
          (loop for i from a upto b do
                (insert (format " %s" (kurecolor-hex-set-hue color (/ (* i 10) 360.0)))))
          (newline-and-indent))))

(defun search-for-nearest-hex-color (p)
  "Search to the nearest hex color.
Use negative prefix P to go backward."
  (interactive "p")
  (let ((regexp "#[0-9a-fA-F]\\{3,6\\}"))
    (if (> p 0)
        (search-forward-regexp regexp)
      (search-backward-regexp regexp))))

(defun get-position-of-nearest-matching (s &optional arg)
  "Get the position of nearest S.

optional ARG when less than zero, default to the before match
when matches are equidistant from the current point."
  (let* ((after      (- (save-excursion (search-forward s)) (length s)))
         (before       (save-excursion (search-backward s)))
         (dist-after   (- after  (point)))
         (dist-before  (- (point) before)))
    (if (eq dist-after dist-before)
        (if (and arg (>= 0 arg)) after before)
      (if (< dist-after dist-before)
          after
        before))))

(defun jump-to-nearest (s)
  "Jump to the nearest match of S."
  (interactive "sJump to nearest: ")
  (let ((u (prefix-numeric-value current-prefix-arg)))
    (goto-char (get-position-of-nearest-matching s u))))

(defun snippy-comment ()
  "Insert a snip line - - 8< - - - comment."
  (interactive)
  (end-of-line)
  (newline)
  (insert "- - 8<")
  (cl-loop repeat 60 do (insert " -"))
  (beginning-of-line)
  (comment-region (point-at-bol) (point-at-eol)))

(defun flush-blank-lines ()
  "Flush blank lines."
  (interactive)
  (flush-lines "^\s*$" nil nil t))

(defun edit-handy-functions ()
  "Open handy-functions.el for editing."
  (interactive)
  (find-file "~/.emacs.d/custom/handy-functions.el"))

(defun copy-region-to-other-window ()
  "Copy the current region to the other window."
  (interactive)
  (if (region-active-p)
      (progn
        (kill-ring-save (region-beginning) (region-end))
        (other-window 1)
        (cua-paste prefix-arg))
    (message "no region selected")))

(defun switch-to-minibuffer-window ()
  "Switch to minibuffer window (if active)."
  (interactive)
  (when (active-minibuffer-window)
    (select-frame-set-input-focus (window-frame (active-minibuffer-window)))
    (select-window (active-minibuffer-window))))

(global-set-key (kbd "<f12>") 'switch-to-minibuffer-window)

(defun replace-regexp-and-return (from to)
  "Replace regexp FROM to TO and return cursor to point."
  (save-excursion
    (while (re-search-forward from nil t)
      (replace-match to))))

(defun replace-pretty-quotes ()
  "Replace pretty quotes with standard quotes."
  (interactive)
  (replace-regexp-and-return "[”“]" "\""))

(defun kilobyte (n)
  "N kilobytes to bytes."
  (* n 1024))
(defalias 'Kb 'kilobyte)

(defun megabyte (n)
  "N megabytes to bytes."
  (* (kilobyte n) 1024))
(defalias 'Mb 'megabyte)

(defun gigabyte (n)
  "N gigabytes to bytes."
  (* (megabyte n) 1024))
(defalias 'Gb 'gigabyte)

(defun terabyte (n)
  "N terabytes to bytes."
  (* (gigabyte n) 1024))
(defalias 'Tb 'terabyte)

(defun github-browse-repo (repo)
  "Browse a github REPO by supplying the user/reponame."
  (interactive "sGithub Repo [format: user/repo]: ")
  (browse-url (format "https://github.com/%s" repo)))

(require 'github-browse-file)
(defun github-browse-this-repo ()
  "Browse the current github."
  (interactive)
  (if (github-browse-file--relative-url)
      (browse-url (concat "https://github.com/" (github-browse-file--relative-url))))
  (message "Not a github repo"))

(defun open-this-in-intellij-idea-15-osx ()
  "Open the current file in intellij IDEA 15 (OS X specific)."
  (interactive)
  (when (file-exists-p (buffer-file-name))
      (start-process-shell-command "intellij-idea" nil
                                   (format "idea --line %s %s"
                                           (line-number-at-pos)
                                           (buffer-file-name)))
      (start-process-shell-command "switch-to-intellij" nil
                                   "osascript -e 'activate application \"IntelliJ IDEA\"'")))

(defun csv--to-lists (string)
  (mapcar (lambda (line) (split-string line ","))
          (split-string (s-chomp string) "\n")))

(defun markdown--csv-to-table (csv)
  "Turn a CSV into a markdown table."
  (string-join (mapcar
                (lambda (line)
                  (setq line (format "| %s |" line))
                  (s-replace "," " | " line))
                (split-string (s-chomp csv) "\n")) "\n"))

(defun markdown-csv-to-table (begin end)
  (interactive "r")
  (unless (region-active-p)
    (error "csv text region must be selected"))
  (let ((table (markdown--csv-to-table (buffer-substring begin end))))
    (delete-region begin end)
    (goto-char begin)
    (insert table)))

(defun markdown--table-header (table)
  "Make the first row of a markdown table a header."
  (let* ((rows (split-string table "\n"))
         (head (car rows))
         (separator (replace-regexp-in-string "[^\|]" "-" head))
         (tail (cdr rows)))
    (string-join (-flatten (list  head separator tail)) "\n")))

(defun markdown-table-header (begin end)
  (interactive "r")
  (unless (region-active-p)
    (error "markdown table text region must be selected"))
  (let ((table (markdown--table-header (buffer-substring begin end))))
    (delete-region begin end)
    (goto-char begin)
    (insert table)))

(defun my-multi-occur-in-matching-buffers (regexp &optional allbufs)
  "Show all lines matching REGEXP in all buffers.
Optionally check ALLBUFS."
  (interactive (occur-read-primary-args))
  (multi-occur-in-matching-buffers ".*" regexp))

(global-set-key (kbd "M-s-/") 'my-multi-occur-in-matching-buffers)

(defun my-isearch-buffers ()
  "Incremental search through open buffers."
  (interactive)
  (multi-isearch-buffers
   (delq nil (mapcar (lambda (buf)
                       (set-buffer buf)
                       (and (not (equal major-mode 'dired-mode))
                            (not (string-match "^[ *]" (buffer-name buf)))
                            buf))
                     (buffer-list)))))

;; Kbd Macroland

;; Pad a single space inside a braced expression,
;;
;; ie. {test} becomes { test }
;;
;; NOTE: cursor must start ahead of the target expression
(fset 'pad-inside-braces
   [?\C-s ?\{ return ?  ?\C-s ?\} return left ?  right])

(defun make-yas-from-region (b e)
  "Make a parameterless yasnippet from the current region B E."
  (interactive "r")
  (if (region-active-p)
      (progn
        ;; TODO make a new buffer with yas headers
        ;; ask for a name
        (let* ((name (read-from-minibuffer "Name: "))
               (key (read-from-minibuffer "Key: "))
               (filename (format "%ssnippets/%s/%s" user-emacs-directory major-mode name))
               (snippet (buffer-substring b e))
               (template (format "# -*- mode: snippet -*-
# name: %s
# key: %s
# --
%s
"
                                name
                                key
                                snippet)))
          (with-temp-buffer
            (insert template)
            (write-file filename)))
        (yas-reload-all))
        (error "An active region is needed to make a snippet")))

(defun reload-emacs ()
  (interactive)
  (if (bufferp (get-file-buffer "init.el"))
      (save-buffer (get-buffer "init.el")))
  (load-file "~/.emacs.d/init.el")
  (message "Reloaded Emacs configuration successfully."))

(defun elpa-package-insert-ends-here ()
  "Insert the ELPA package file ending string.

\(When it's missing\)"
  (interactive)
  (if (and buffer-file-name (string-match "emacs-lisp" (format "%s" major-mode)))
      (let* ((filename (file-name-base))
            (end-file-message (format  ";;; %s.el ends here" filename)))
        (goto-char (point-max))
        (unless (looking-back end-file-message nil)
          (insert end-file-message)))
    (message "Not a lisp file.")))

;; Key bindings
(global-set-key (kbd "C-c M-+")   'increase-default-font-height)
(global-set-key (kbd "C-c M--")   'decrease-default-font-height)
(global-set-key (kbd "C-c =")     'set-default-font-height)
(global-set-key (kbd "ESC M-d")   'kill-whole-word)
(global-set-key (kbd "C-c ESC h") 'edit-handy-functions)
(global-set-key (kbd "C-c ESC c") 'copy-region-to-other-window)
(global-set-key (kbd "C-a")       'smart-beginning-of-line)
(global-set-key (kbd "C-S-o")     'open-line-above)
(global-set-key (kbd "C-o")       'open-line-below)
(global-set-key (kbd "ESC M-p")   'describe-thing-in-popup)
(global-set-key (kbd "ESC M-i")   'describe-thing-at-point)
(global-set-key (kbd "ESC M-z")   'zap-up-to-string)
(global-set-key (kbd "ESC C-M-z") 'zap-up-to-regexp)

;; Case transform hydra
(global-set-key (kbd "C-c x") (defhydra case-transform ()
                                  "Transform case of word or region"
                                 ("h" humanize-at-point-or-region "humanize")
                                  ("d" dasherise-at-point-or-region "dasherise/kebab")
                                  ("u" upper-camelcase-at-point-or-region "upper-camel")
                                  ("l" lower-camelcase-at-point-or-region "lower-camel")
                                  ("s" snake-case-at-point-or-region "snake/underscore")
                                  ("t" titleized-at-point-or-region "titleized")))

(provide 'handy-functions)
;;; handy-functions.el ends here
