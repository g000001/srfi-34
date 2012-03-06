;;;; srfi-34.asd -*- Mode: Lisp;-*-

(cl:in-package :asdf)

(defsystem :srfi-34
  :serial t
  :depends-on (:fiveam
               :mbe
               :srfi-23)
  :components ((:file "package")
               (:file "util")
               (:file "srfi-34")
               (:file "test")))

(defmethod perform ((o test-op) (c (eql (find-system :srfi-34))))
  (load-system :srfi-34)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :srfi-34.internal :srfi-34))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))
