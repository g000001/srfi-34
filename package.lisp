;;;; package.lisp

(cl:in-package :cl-user)


(defpackage "https://github.com/g000001/srfi-34"
  (:use)
  (:export
   with-exception-handler
   guard
   raise ))


(defpackage "https://github.com/g000001/srfi-34#internals"
  (:use "https://github.com/g000001/srfi-34"
        cl
        fiveam mbe)
  (:shadowing-import-from
   "https://github.com/g000001/srfi-23" error)
  (:shadow lambda member assoc map loop))


;;; *EOF*
