;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Handles the multiple render passes and submission to the OpenVR compositor.

(in-package :trial-vr)

(trial:define-subject head (trial:camera)
  ((left-eye :initarg :left-eye :accessor left-eye)
   (right-eye :initarg :right-eye :accessor right-eye)
   (hmd-pose :initarg :hmd-pose :accessor hmd-pose)
   (current-eye :initarg :current-eye :accessor current-eye))
  (:default-initargs
   :name :head
   :current-eye :left))

(defparameter *left-render-pass* nil)
(defparameter *right-render-pass* nil)
(defparameter *compositor-render-pass* nil)
(defparameter *head* nil)
(defparameter *hmd-pose* (3d-matrices:meye 4))

(trial:define-shader-pass eye-render-pass (trial:render-pass) ())

(trial:define-shader-pass left-eye-render-pass (eye-render-pass)
  ((trial:color :port-type trial:output :attachment :color-attachment0
                :texspec (:target :texture-2d))
   (trial:depth :port-type trial:output :attachment :depth-stencil-attachment
                :texspec (:target :texture-2d))))

(trial:define-shader-pass right-eye-render-pass (eye-render-pass)
  ((trial:color :port-type trial:output :attachment :color-attachment0
                :texspec (:target :texture-2d))
   (trial:depth :port-type trial:output :attachment :depth-stencil-attachment
                :texspec (:target :texture-2d))))

(trial:define-shader-pass compositor-render-pass (trial:render-pass)
  ((left-pass-color :port-type trial:input)
   (right-pass-color :port-type trial:input)
   (left-pass-depth :port-type trial:input)
   (right-pass-depth :port-type trial:input)))

(defmethod trial:project-view ((camera head) ev)
  (trial:reset-matrix (trial:projection-matrix))
  (trial:reset-matrix (trial:view-matrix))
  (when (or (eq (current-eye camera) :left) t)
    (setf (trial:projection-matrix) (get-eye-projection (current-eye camera))))
  (when (or (eq (current-eye camera) :right) t)
    (setf (trial:view-matrix) (3d-matrices:m* (get-eye-pose (current-eye camera)) *hmd-pose*))))

(let ((time 0))
  (trial:define-handler (head trial::tick) (ev)
    (incf time (trial::dt ev))
    (when (> time (/ 30))
      (setf time 0)
      (setf *hmd-pose* (get-latest-hmd-pose))
      (when *left-render-pass* (submit-to-compositor *left-render-pass*))
      (when *right-render-pass* (submit-to-compositor *right-render-pass*)))))

(defmethod trial:setup-perspective ((camera head) ev)
  (setf (trial:projection-matrix) (get-eye-projection :left)))

(defmethod trial:paint :before ((subject trial:pipelined-scene) (pass left-eye-render-pass))
  (setf (current-eye *head*) :left)
  (trial:project-view *head* nil))

(defmethod trial:paint :before ((subject trial:pipelined-scene) (pass right-eye-render-pass))
  (setf (current-eye *head*) :right)
  (trial:project-view *head* nil))

(defmethod trial:paint ((subject trial:pipelined-scene) (pass compositor-render-pass)))

(defun texture-id (eye-render-pass)
  (trial:data-pointer (cadar (trial:attachments (trial:framebuffer eye-render-pass)))))

(defun render-pass-side (eye-render-pass)
  (if (typep eye-render-pass 'left-eye-render-pass) :left :right))

(defun submit-to-compositor (eye-render-pass)
  (vr::vr-compositor)
  (when vr::*compositor* 
    (vr::submit
     (render-pass-side eye-render-pass)
     `(vr::handle ,(texture-id eye-render-pass) vr::type :open-gl vr::color-space :gamma))))
