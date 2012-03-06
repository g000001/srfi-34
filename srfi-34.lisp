;;;; srfi-34.lisp

(cl:in-package :srfi-34.internal)

(define-condition srfi-34-condition (condition)
  ((obj :initarg :obj)))

#|(defvar *current-exception-handlers*
  (list (lambda (condition)
          (error "unhandled exception" condition))))|#

#|(define-function (with-exception-handler handler thunk)
  (with-exception-handlers (cons handler *current-exception-handlers*)
                           thunk))|#

(defun with-exception-handler (handler thunk)
  (handler-bind ((srfi-34-condition (lambda (x)
                                      (funcall handler (slot-value x 'obj))))
                 (condition handler))
    (funcall thunk)))

#|(define-function (with-exception-handlers new-handlers thunk)
  (let ((previous-handlers *current-exception-handlers*))
    (dynamic-wind
      (lambda ()
        (set! *current-exception-handlers* new-handlers))
      thunk
      (lambda ()
        (set! *current-exception-handlers* previous-handlers)))))|#

#|(define-function (raise obj)
  (let ((handlers *current-exception-handlers*))
    (with-exception-handlers (cdr handlers)
      (lambda ()
        (arnesi:kall (car handlers) obj)
        (error "handler returned"
               (car handlers)
               obj)))))|#

(defun raise (obj)
  (signal (make-condition 'srfi-34-condition :obj obj)))

(define-syntax guard
  (syntax-rules ()
    ((guard (var clause ***) e1 e2 ***)
     (with ((k (gensym "K-")))
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


;;; eof
