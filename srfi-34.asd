;;;; srfi-34.asd -*- Mode: Lisp;-*-

(cl:in-package :asdf)

(defsystem :srfi-34
  :version "20200224"
  :description "SRFI 34 for CL: Exception Handling for Programs"
  :long-description "SRFI 34 for CL: Exception Handling for Programs
https://srfi.schemers.org/srfi-34"
  :author "Richard Kelsey, Michael Sperber"
  :maintainer "CHIBA Masaomi"
  :serial t
  :depends-on (:fiveam
               :mbe
               :srfi-23)
  :components ((:file "package")
               (:file "util")
               (:file "srfi-34")
               (:file "test")))


(defmethod perform :after ((o load-op) (c (eql (find-system :srfi-34))))
  (let ((name "https://github.com/g000001/srfi-34")
        (nickname :srfi-34))
    (if (and (find-package nickname)
             (not (eq (find-package nickname)
                      (find-package name))))
        (warn "~A: A package with name ~A already exists." name nickname)
        (rename-package name name `(,nickname)))))


(defmethod perform ((o test-op) (c (eql (find-system :srfi-34))))
  (let ((*package*
         (find-package
          "https://github.com/g000001/srfi-34#internals")))
    (eval
     (read-from-string
      "
      (or (let ((result (run 'srfi-34)))
            (explain! result)
            (results-status result))
          (error \"test-op failed\") )"))))
