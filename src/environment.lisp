;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Handles launching the workbench as well as starting and closing the OpenVR environment.

(in-package :trial-vr)

(defmethod trial:start :before ((main workbench))
  "Set up OpenVR environment."
  ;(cffi:use-foreign-library 3b-openvr::openvr-api)
  (setf vr::*%init* (vr::vr-init :scene)))

(defmethod trial:finalize :after ((main workbench))
  "Shut down OpenVR environment."
  (vr::vr-shutdown-internal)
  (setf vr::*%init* nil)
  ;(cffi:close-foreign-library 3b-openvr::openvr-api)
  ) ; Hack to try to prevent SteamVR crashing.

(defun launch (&key (own-thread nil))
  "Launch the trial VR workbench."
  (let ((call-lambda (lambda () (trial:launch 'workbench :width 640 :height 480))))
    (if own-thread
        (bt:make-thread call-lambda)
        (funcall call-lambda))))

(export 'launch)
(setf vr::*%init nil vr::*system* nil vr::*chaperone* nil vr::*compositor* nil)
