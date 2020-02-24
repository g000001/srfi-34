;;;; srfi-34.lisp

(cl:in-package "https://github.com/g000001/srfi-34#internals")


(define-condition srfi-34-condition (condition)
  ((obj :initarg :obj)))


(defun with-exception-handler (handler thunk)
  (handler-bind ((srfi-34-condition (lambda (x)
                                      (funcall handler (slot-value x 'obj))))
                 (condition handler))
    (funcall thunk)))


(defun raise (obj)
  (signal (make-condition 'srfi-34-condition :obj obj)))


(define-syntax guard
  (syntax-rules ()
    ((guard (var clause ***) e1 e2 ***)
     (with ((k (gensym "GUARD.K-"))
            (c (gensym "GUARD.C-"))
            (condition (gensym "GUARD.CONDITION-"))
            (args (gensym "GUARD.ARGS")))
       (block k
         (with-exception-handler
             (lambda (c)
               (return-from k
                 (funcall
                  (lambda (condition)
                    (let ((var condition))      ; clauses may SET! var
                      (declare (ignorable var))
                      (guard-aux (return-from k (raise var))
                                 clause ***)))
                  c)))
             (lambda ()
               (call-with-values
                (lambda () e1 e2 ***)
                (lambda args
                  (apply #'values args) )))))))))


(define-syntax guard-aux
  (syntax-rules (:else :=>)
    ((guard-aux reraise (:else result1 result2 ***))
     (begin result1 result2 ***))
    ((guard-aux reraise (test :=> result))
     (let ((temp test))
       (if temp
           (funcall result temp)
           reraise)))
    ((guard-aux reraise (test :=> result) clause1 clause2 ***)
     (let ((temp test))
       (if temp
           (funcall result temp)
           (guard-aux reraise clause1 clause2 ***))))
    ((guard-aux reraise (test))
     test)
    ((guard-aux reraise (test) clause1 clause2 ***)
     (let ((temp test))
       (if temp
           temp
           (guard-aux reraise clause1 clause2 ***))))
    ((guard-aux reraise (test result1 result2 ***))
     (if test
         (begin result1 result2 ***)
         reraise))
    ((guard-aux reraise (test result1 result2 ***) clause1 clause2 ***)
     (if test
         (begin result1 result2 ***)
         (guard-aux reraise clause1 clause2 ***)))))


;;; *EOF*
