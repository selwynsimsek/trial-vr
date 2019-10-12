;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Debug routines that can be carried out while the trial-vr scene is up and running.

(in-package :trial-vr)

(defmacro trace-for-one-second (&rest specs)
  `(progn
     (trace ,@specs)
     (sleep 1)
     (untrace ,@specs)))

(defun print-render-info () )

(defun print-view-projection-info ()
  (map nil 'print (list (trial:view-matrix) (trial:projection-matrix))))

(defun hmd-info ()
  (map nil #'print (list
                    (get-eye-projection :left)
                    (get-eye-projection :right)
                    (get-eye-pose :left)
                    (get-eye-pose :right)
                    (get-latest-hmd-pose))))

