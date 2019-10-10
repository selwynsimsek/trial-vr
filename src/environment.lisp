;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Handles launching the workbench as well as starting and closing the OpenVR environment.

(in-package :trial-vr)

(defmethod trial:start :before ((main workbench))
  "Set up OpenVR environment."
  (setf vr::*%init* (vr::vr-init :scene)))

(defmethod trial:finalize :after ((main workbench))
  "Shut down OpenVR environment."
  (vr::vr-shutdown-internal)
  (setf vr::*%init* nil))

(defun launch ()
  "Launch the trial VR workbench."
  (setf vr::*%init nil vr::*system* nil vr::*chaperone* nil vr::*compositor* nil)
  (bt:make-thread (lambda () (trial:launch 'workbench :width 926 :height 1028))))

(export 'launch)
