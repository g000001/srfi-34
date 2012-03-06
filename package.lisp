;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :srfi-34
  (:use)
  (:export
   :with-exception-handler
   :guard
   :raise ))

(defpackage :srfi-34.internal
  (:use :srfi-34 :cl :fiveam :mbe)
  (:shadowing-import-from :srfi-23 :error)
  (:shadow :lambda :member :assoc :map :loop))
