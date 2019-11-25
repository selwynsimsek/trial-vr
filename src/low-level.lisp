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
  (sb->3d (sb-cga:inverse-matrix (vr::get-eye-to-head-transform side))))

(defun get-eye-projection (side &key (near 0.1f0) (far 10000000.0f0))
  "Returns the per eye projection matrix."
  (sb->3d (vr::get-projection-matrix side near far)))

(let ((poses (make-array (list vr::+max-tracked-device-count+) :initial-element nil)))
  (defun wait-get-poses ()
    (vr::wait-get-poses poses nil))
  (defun get-latest-hmd-pose ()
    (vr::wait-get-poses poses nil)
    (if (aref poses vr::+tracked-device-index-hmd+)
        (sb->3d (vr::device-to-absolute-tracking (aref poses vr::+tracked-device-index-hmd+)))
        (3d-matrices:meye 4))))

(defun eye-framebuffer-size ()
  "Returns the recommended render target size. Defaults to that of the HTC Vive."
  (vr::get-recommended-render-target-size))

(defun trigger-haptic-pulse (controller-id &key (axis-id 0) (duration 100))
  "Triggers a haptic pulse. The duration is measured in microseconds."
  (vr::%trigger-haptic-pulse *system* controller-id axis-id duration))
