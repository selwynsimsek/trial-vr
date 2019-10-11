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

(defparameter *left-render-pass* nil)
(defparameter *right-render-pass* nil)
(defparameter *head* nil)
(trial:define-shader-pass eye-render-pass (trial:render-pass)
  ((trial:color :port-type trial:output :attachment :color-attachment0 :texspec #1=(:target :texture-2d) )
   (trial:depth :port-type trial:output :attachment :depth-stencil-attachment :texspec #1#)))

(trial:define-shader-pass left-eye-render-pass (eye-render-pass)
  ())

(trial:define-shader-pass right-eye-render-pass (eye-render-pass)
  ())

(defmethod trial:project-view ((camera head) ev)
  (setf trial:*view-matrix* (3d-matrices:m*
                             (get-eye-pose (current-eye camera))
                             (hmd-pose camera)))
  (setf trial:*projection-matrix* (get-eye-projection (current-eye camera))))
                                        ; need to set up projection matrix on the tick as well 

(defmethod trial:setup-perspective ((camera head) ev)
  (setf trial:*projection-matrix* (get-eye-projection :left)))

(defmethod trial:paint :around ((subject trial:pipelined-scene) (pass left-eye-render-pass))
  (setf (current-eye *head*) :left)
  (trial:project-view *head* nil)
  (call-next-method subject pass))

(defmethod trial:paint :around ((subject trial:pipelined-scene) (pass right-eye-render-pass))
  (setf (current-eye *head*) :right)
  (trial:project-view *head* nil)
  (call-next-method subject pass))

(defmethod trial:render :around ((source workbench) (target trial:display))
  (call-next-method source target)
  (when *left-render-pass* (submit-to-compositor *left-render-pass*))
  (when *right-render-pass* (submit-to-compositor *right-render-pass*)))


(defun texture-id (eye-render-pass)
  (trial:data-pointer (cadar (trial:attachments (trial:framebuffer eye-render-pass)))))

                                        ;(texture-id *right-render-pass*)
(defun submit-to-compositor (eye-render-pass)
  (vr::vr-compositor)
  (when vr::*compositor*
                                        ; (format t "C")
    (format t "~{~a ~}~%" (list vr::*compositor* (typep eye-render-pass 'left-eye-render-pass) (texture-id eye-render-pass)))
    (vr::submit
     (if (typep eye-render-pass 'left-eye-render-pass) :left :right)
     (list 'vr::handle (texture-id eye-render-pass) 'vr::type :open-gl 'vr::color-space :gamma))))

(progn
  (trace trial:paint)
  (sleep 1)
  (untrace trial:paint))
