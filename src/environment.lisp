;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Handles launching the workbench as well as starting and closing the OpenVR environment.

(in-package :trial-vr)

(defvar *app-id* 480 "Steamworks App ID - for now using the App ID of the example game.")
(defvar *steamworks-client* nil)

(defmethod trial:start :before ((main workbench))
  "Set up OpenVR, sound, Steamworks."
  (setf vr::*%init* (vr::vr-init :scene))
  (vr::clear)
  (vr::vr-system)
  (vr::vr-chaperone)
  (vr::vr-chaperone-setup)
  (vr::vr-compositor)
  (vr::vr-overlay)
  (vr::vr-resources)
  (vr::vr-render-models)
  (vr::vr-extended-display)
  (vr::vr-settings)
  (vr::vr-applications)
  (vr::vr-tracked-camera)
  (vr::vr-screenshots)
  (vr::vr-driver-manager)
  (vr::vr-input)
  (vr::vr-io-buffer)
  (vr::vr-spatial-anchors)
  (vr::vr-debug)
  (vr::vr-notifications)
  (harmony-simple:initialize)
  (3b-openvr::create-overlay "abc" "def")
  (unless *steamworks-client*
    (setf *steamworks-client* (make-instance 'cl-steamworks:steamworks-client :app-id *app-id*))))

(defmethod trial:finalize :after ((main workbench))
  "Shut down OpenVR environment."
  (vr::clear)
  (vr::vr-shutdown-internal)
  (when *steamworks-client*
    (cl-steamworks:free (cl-steamworks:steamworks))
    (setf *steamworks-client* nil)))

(defun launch (&key (own-thread nil))
  "Launch the trial VR workbench."
  (let ((call-lambda (lambda () (trial:launch 'workbench :width 160 :height 120))))
    (if own-thread
        (bt:make-thread call-lambda)
        (funcall call-lambda))))

(export 'launch)
