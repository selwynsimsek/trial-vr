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
   :near-plane 0.001f0
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
(defparameter *compositor-render-pass* nil)

(defparameter *head* nil)
(defparameter *hmd-pose* (3d-matrices:meye 4))
(trial:define-shader-pass eye-render-pass (trial:render-pass)
  ())

(trial:define-shader-pass left-eye-render-pass (eye-render-pass)
  ((trial:color :port-type trial:output :attachment :color-attachment0 :texspec (:target :texture-2d))
   (trial:depth :port-type trial:output :attachment :depth-stencil-attachment :texspec (:target :texture-2d))))

(trial:define-shader-pass right-eye-render-pass (eye-render-pass)
  ((trial:color :port-type trial:output :attachment :color-attachment0 :texspec (:target :texture-2d))
   (trial:depth :port-type trial:output :attachment :depth-stencil-attachment :texspec (:target :texture-2d))))

(trial:define-shader-pass compositor-render-pass (trial:render-pass)
  ((left-pass-color :port-type trial:input)
   (right-pass-color :port-type trial:input)
   (left-pass-depth :port-type trial:input)
   (right-pass-depth :port-type trial:input)))

(defmethod trial:project-view ((camera head) ev)
                                        ; (princ (current-eye camera))
  (trial:reset-matrix (trial:projection-matrix))
  (trial:reset-matrix (trial:view-matrix))
  (when (or (eq (current-eye camera) :left) t)
    (setf (trial:projection-matrix) (get-eye-projection (current-eye camera))))
  (when (or (eq (current-eye camera) :right) t)
    (setf (trial:view-matrix) (3d-matrices:m*
                               (get-eye-pose (current-eye camera))
                               *hmd-pose*))))

(let ((time 0))
  (trial:define-handler (head trial::tick) (ev)
    (incf time (trial::dt ev))
    (when (> time (/ 30))
      ;(print head)
      (setf time 0)
      (setf *hmd-pose* (get-latest-hmd-pose))
      (when *left-render-pass* (submit-to-compositor *left-render-pass*))
      (when *right-render-pass* (submit-to-compositor *right-render-pass*)))))
                                        ; need to set up projection matrix on the tick as well 

(defmethod trial:setup-perspective ((camera head) ev)
  (setf (trial:projection-matrix) (get-eye-projection :left)))

(defmethod trial:paint :before ((subject trial:pipelined-scene) (pass left-eye-render-pass))
  (setf (current-eye *head*) :left)
  (trial:project-view *head* nil))

(defmethod trial:paint :before ((subject trial:pipelined-scene) (pass right-eye-render-pass))
  (setf (current-eye *head*) :right)
  (trial:project-view *head* nil))

(defmethod trial:paint ((subject trial:pipelined-scene) (pass compositor-render-pass))
  )

(defun texture-id (eye-render-pass)
  (trial:data-pointer (cadar (trial:attachments (trial:framebuffer eye-render-pass)))))

                                        ;(texture-id *right-render-pass*)
(defun submit-to-compositor (eye-render-pass)
  (vr::vr-compositor)
  (when vr::*compositor*
                                        ; (format t "C")
                                        ;(format t "~{~a ~}~%" (list vr::*compositor* (typep eye-render-pass 'left-eye-render-pass) (texture-id eye-render-pass)))
    
    (vr::submit
     (if (typep eye-render-pass 'left-eye-render-pass) :left :right)
     (list 'vr::handle (texture-id eye-render-pass) 'vr::type :open-gl 'vr::color-space :gamma))))

(defmacro trace-for-one-second (&rest specs)
  `(progn
    (trace ,@specs)
    (sleep 1)
    (untrace ,@specs)))

(defun print-render-info ()
  (map nil #'describe (list *head* *left-render-pass* *right-render-pass*
                            (trial:framebuffer *left-render-pass*)
                            (trial:framebuffer *right-render-pass*)
                            (cadar (trial:attachments (trial:framebuffer *left-render-pass*)))
                            (cadar (trial:attachments (trial:framebuffer *right-render-pass*))))))

(defun print-view-projection-info ()
  (map nil 'print (list trial::*view-matrix* trial::*projection-matrix*)))
;(print-render-info)
;(trace-for-one-second trial:project-view %gl:uniform-matrix-4fv)
                     ;(trial:maybe-reload-scene)
;(print-view-projection-info)
                                        ;(hmd-pose *head*)
                                        ;*hmd-pose*
;(get-latest-hmd-pose)
;trial:reset-matrix
