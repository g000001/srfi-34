(cl:in-package :srfi-34.internal)

(def-suite srfi-34)

(in-suite srfi-34)

(defmacro progn-with-output-to-string ((out) &body body)
  `(let ((,out (make-string-output-stream)))
     (list
      (progn ,@body)
      (get-output-stream-string ,out))))

(defmacro isqu (x y)
  `(is (equal ,x ,y)))

(test with-exception-handler
  ;;
  (isqu (progn-with-output-to-string (s)
          (block k
            (with-exception-handler (lambda (x)
                                      (princ "condition: " s)
                                      (princ x s)
                                      (return-from k 'exception) )
              (lambda ()
                (+ 1 (raise 'an-error)) ))))
        '(exception "condition: AN-ERROR") )
  (signals (cl:error)
    (with-output-to-string (w)
      (block k
        (with-exception-handler (lambda (x)
                                  (declare (ignore x))
                                  (display "something went wrong" w)
                                  ;; then behaves in an unspecified way
                                  'dont-care )
          (lambda ()
            (+ 1 (raise 'an-error)) )))) )
  ;;
  (isqu (progn-with-output-to-string (w)
          (guard (condition
                  (:else
                   (display "condition: " w)
                   (princ condition w)
                   'exception ))
                 (+ 1 (raise 'an-error)) ))
        '(EXCEPTION "condition: AN-ERROR") )
  ;;
  (isqu (progn-with-output-to-string (w)
          (guard (condition
                  (:else
                   (display "something went wrong" w)
                   'dont-care ))
                 (+ 1 (raise 'an-error)) ))
        '(DONT-CARE "something went wrong") )
  ;;
  (isqu (block k
          (with-exception-handler (lambda (x)
                                    (display "reraised ") (write x) (newline)
                                    (return-from k 'zero) )
            (lambda ()
              (guard (condition
                      ((positive? condition) 'positive)
                      ((negative? condition) 'negative) )
                     (raise 1) ))))
        'POSITIVE )
  ;;
  (isqu (block k
          (with-exception-handler (lambda (x)
                                    (display "reraised ") (write x) (newline)
                                    (return-from k 'zero) )
            (lambda ()
              (guard (condition
                      ((positive? condition) 'positive)
                      ((negative? condition) 'negative) )
                     (raise -1) ))))
        'NEGATIVE )
  ;;
  (isqu (guard (condition
                ((assq 'a condition) :=> #'cdr)
                ((assq 'b condition)) )
               (raise (list (cons 'a 42))) )
        42 )
  ;;
  (isqu (guard (condition
                ((assq 'a condition) :=> #'cdr)
                ((assq 'b condition)) )
               (raise (list (cons 'b 23))) )
        '(B . 23) )
  ;;
  (isqu
   (progn-with-output-to-string (w)
     (block k
       (with-exception-handler (lambda (x)
                                 (display "reraised " w)
                                 (princ x w)
                                 (return-from k 'zero) )
         (lambda ()
           (guard (condition
                   ((positive? condition) 'positive)
                   ((negative? condition) 'negative) )
                  (raise 0) )))))
   '(ZERO "reraised 0") ))
