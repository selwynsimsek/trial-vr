;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package :trial-vr)

(trial:define-subject head (trial:camera)
  ((left-eye :initarg :left-eye :accessor left-eye)
   (right-eye :initarg :right-eye :accessor right-eye)
   (hmd-pose :initarg :hmd-pose :accessor hmd-pose)
   (current-eye :initarg :current-eye :accessor current-eye)
   (fov :initarg :fov :accessor fov))
  (:default-initargs
   :name :head
   :location (trial::vec 0 30 200)
   :fov 75
   :current-eye :left
   :near-plane 0.01f0
   :hmd-pose (3d-matrices:meye 4)
   :far-plane 1000000.0f0
   :left-eye (make-instance 'eye :side :left)
   :right-eye (make-instance 'eye :side :right)))

(trial:define-subject eye (trial:located-entity)
  ((side :initarg :side :accessor side)
   (pose :initarg :pose :accessor pose)
   (projection :initarg :projection :accessor projection))
  (:default-initargs
   :name :eye
   :side nil
   :pose (3d-matrices:meye 4)
   :projection (3d-matrices:meye 4)))

(defmethod trial:setup-perspective ((camera head) ev)
  (trial:perspective-projection (fov camera) (/ (trial:width ev) (max 1 (trial:height ev)))
                                (trial:near-plane camera) (trial:far-plane camera))
  (get-eye-projection (current-eye camera)))

(let ((time 0))
  (trial:define-handler (head trial::tick) (ev)
    (incf time (trial::dt ev))
    (when (> time (/ 30))
      (setf time 0)
      (setf (pose (left-eye head))
            (get-eye-pose :left)
            
            (pose (right-eye head))
            (get-eye-pose :right)
            
            (projection (left-eye head))
            (get-eye-projection :left)
            
            (projection (right-eye head))
            (get-eye-projection :right)
            
            (hmd-pose head)
            (get-latest-hmd-pose))
      (submit-to-compositor *left-render-pass*)
      (submit-to-compositor *right-render-pass*))))
(defparameter *left-render-pass* nil)
(defparameter *right-render-pass* nil)
(defparameter *head* nil)

(trial:define-shader-pass eye-render-pass ()
  ())

(trial:define-shader-pass left-eye-render-pass (eye-render-pass trial:render-pass)
  ((trial:color :port-type trial:output :attachment :color-attachment0 :texspec (:target :texture-2d) )
   (trial:depth :port-type trial:output :attachment :depth-stencil-attachment :texspec (:target :texture-2d))))

(trial:define-shader-pass right-eye-render-pass (eye-render-pass trial:render-pass)
  ((trial:color :port-type trial:output :attachment :color-attachment1 :texspec (:target :texture-2d) )
   (trial:depth :port-type trial:output :attachment :depth-stencil-attachment :texspec (:target :texture-2d))))

(defmethod trial:project-view ((camera head) ev)
  (setf trial:*view-matrix* (3d-matrices:m*

                             (get-eye-pose (current-eye camera))
                             (hmd-pose camera)))
  (setf trial:*projection-matrix* (get-eye-projection (current-eye camera))))

(defmethod trial:paint-with :around ((pass eye-render-pass) thing)
  (setf (current-eye *head*)  (if (typep pass 'left-eye-render-pass)
                                  :left :right))
  (call-next-method))
