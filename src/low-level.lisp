;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Convenience layer that fetches poses and projection matrices from 3b-openvr.

(in-package :trial-vr)

(defun sb->3d (matrix)
  "Convenience method to convert matrices from sb-cga to 3d-matrices.
   3b-openvr uses the former while Trial uses the latter."
  (if (typep matrix 'simple-array)
      (3d-matrices:mat4 matrix)
      (3d-matrices:meye 4)))

(defun get-eye-pose (side)
  "Head to eye transform. Taken from 3b-openvr-hello."
  (vr::vr-system)
  (sb->3d (sb-cga:inverse-matrix (vr::get-eye-to-head-transform side))))

(defun get-eye-projection (side &key (near 0.3f0) (far 100.0f0))
  "Returns the per eye projection matrix."
  (vr::vr-system)
  (sb->3d (vr::get-projection-matrix side near far)))

(let ((poses (make-array (list vr::+max-tracked-device-count+) :initial-element nil)))
  (defun wait-get-poses ()
    (vr::wait-get-poses poses nil))
  (defun get-latest-hmd-pose ()
    (when (and vr::*system* vr::*compositor*)
      (vr::wait-get-poses poses nil)
      (sb->3d (vr::device-to-absolute-tracking  (aref poses vr::+tracked-device-index-hmd+))))))

(defun eye-framebuffer-size ()
  "Returns the recommended render target size. Defaults to that of the HTC Vive."
  (vr::vr-system)
  (if (vr::vr-system)
      (vr::get-recommended-render-target-size)
      (list 1852 2056)))

(defun trigger-haptic-pulse (controller-id &key (axis-id 0) (duration 100))
  "Triggers a haptic pulse. The duration is measured in microseconds."
  (vr::%trigger-haptic-pulse *system* controller-id axis-id duration))
