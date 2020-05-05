;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Handles the multiple render passes and submission to the OpenVR compositor.

(in-package #:org.shirakumo.fraf.trial.vr)

(trial:define-subject head (trial:camera)
  ((hmd-pose :initarg :hmd-pose :accessor hmd-pose)
   (current-eye :initarg :current-eye :accessor current-eye))
  (:default-initargs
   :name :head
   :current-eye :left
   :hmd-pose (3d-matrices:meye 4)))

(trial:define-shader-pass eye-render-pass (trial:render-pass) ())

(progn
  (trial:define-shader-pass left-eye-render-pass (eye-render-pass)
    ((trial:color :port-type trial:output :attachment :color-attachment0
                  :texspec #1=(:target :texture-2d :width 1852 :height 2056)) 
     (trial:depth :port-type trial:output :attachment :depth-stencil-attachment
                  :texspec #1#)))

  (trial:define-shader-pass right-eye-render-pass (eye-render-pass)
    ((trial:color :port-type trial:output :attachment :color-attachment0
                  :texspec #1#)
     (trial:depth :port-type trial:output :attachment :depth-stencil-attachment
                  :texspec #1#))))

(trial:define-shader-pass compositor-render-pass (trial:render-pass)
  ((left-pass-color :port-type trial:input)
   (right-pass-color :port-type trial:input)
   (left-pass-depth :port-type trial:input)
   (right-pass-depth :port-type trial:input)))

(trial:define-shader-pass ui-render-pass (trial:render-pass)
  ((trial:color :port-type trial:output :attachment :color-attachment0
                :texspec (:target :texture-2d :width 640 :height 480))))

(defmethod trial:project-view ((camera head) ev)
  (let ((eye (current-eye camera))
        (left-eye-pose (get-eye-pose :left))
        (right-eye-pose (get-eye-pose :right))
        (current-eye-pose (get-eye-pose (current-eye camera)))
        (hmd-pose (hmd-pose camera)))
    (setf (trial:projection-matrix)
          (3d-matrices:mtranspose (get-eye-projection (current-eye camera)))
          (trial:view-matrix)
          (3d-matrices:mtranspose (3d-matrices:m* (3d-matrices:minv hmd-pose) current-eye-pose)))))

(defmethod trial:setup-perspective ((camera head) ev)
  (setf (trial:projection-matrix) (get-eye-projection :left)))

(defmethod trial:paint :before ((subject trial:pipelined-scene) (pass left-eye-render-pass))
  ;; right place for it?
  #+win32 (org.shirakumo.fraf.trial.vr.windows::interop-pre-frame)
  (setf (current-eye (trial::unit :head subject)) :left)
  (trial:project-view (trial::unit :head subject) nil))

(defmethod trial:paint :before ((subject trial:pipelined-scene) (pass right-eye-render-pass))
  (setf (current-eye (trial::unit :head subject)) :right)
  (trial:project-view (trial::unit :head subject) nil))

(defmethod trial:paint :before ((subject trial:pipelined-scene) (pass ui-render-pass))
  ; set up projection here
  (trial:project-view (make-instance 'trial:2d-camera) nil)) ; does this work?

#-win32
(defmethod trial:paint :after ((subject trial:pipelined-scene) (pass ui-render-pass))
  (let ((texture-id (trial:data-pointer (trial:texture (flow:port pass 'trial:color)))))
    (vr:set-overlay-texture (vr:find-overlay "abc") texture-id)
    (vr:show-overlay (vr:find-overlay "abc"))))
#-win32
(defmethod trial:paint-with ((pass ui-render-pass) thing)
  (when (or (typep thing 'trial:pipelined-scene)
            (typep thing 'dui))
    (call-next-method)))
#-win32
(defmethod trial:paint-with ((pass eye-render-pass) thing)
  (unless (typep thing 'dui) (call-next-method)))

(defmethod trial:paint ((subject trial:pipelined-scene) (pass compositor-render-pass))
  (wait-get-poses)
  (let ((left-texture-id
          (trial:data-pointer (trial:texture (flow:port pass 'left-pass-color))))
        (right-texture-id
          (trial:data-pointer (trial:texture (flow:port pass 'right-pass-color)))))
    (vr::submit :left left-texture-id :compositor vr::*compositor*)
    (vr::submit :right right-texture-id :compositor vr::*compositor*))
  (alexandria:when-let ((latest-pose (get-latest-hmd-pose)))
    (setf (hmd-pose (trial::unit :head subject)) latest-pose)))
