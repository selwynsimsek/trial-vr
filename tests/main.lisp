(defpackage trial-vr/tests/main
  (:use :cl
        :trial-vr
        :rove))
(in-package :trial-vr/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :trial-vr)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
