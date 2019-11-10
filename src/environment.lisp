;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Handles launching the workbench as well as starting and closing the OpenVR environment.

(in-package :trial-vr)

(defun nullify-vr-tables ()
  (setf vr::*%init* (vr::vr-init :scene)
        vr::*system* nil
        vr::*chaperone* nil
        vr::*chaperone-setup* nil
        vr::*compositor* nil
        vr::*overlay* nil
        vr::*resources* nil
        vr::*render-models* nil
        vr::*extended-display* nil
        vr::*settings* nil
        vr::*applications* nil
        vr::*tracked-camera* nil
        vr::*screenshots* nil
        vr::*driver-manager* nil
        vr::*input* nil
        vr::*io-buffer* nil
        vr::*spatial-anchors* nil
        vr::*debug* nil
        vr::*notifications* nil))

(defmethod trial:start :before ((main workbench))
  "Set up OpenVR environment."
  (nullify-vr-tables)
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
  (vr::vr-notifications))

(defmethod trial:finalize :after ((main workbench))
  "Shut down OpenVR environment."
  (nullify-vr-tables)
  (vr::vr-shutdown-internal))

(defun launch (&key (own-thread nil))
  "Launch the trial VR workbench."
  (let ((call-lambda (lambda () (trial:launch 'workbench :width 160 :height 120))))
    (if own-thread
        (bt:make-thread call-lambda)
        (funcall call-lambda))))

(export 'launch)
