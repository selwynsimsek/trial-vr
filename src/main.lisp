(defpackage trial-vr
  (:use :cl)
  (:local-nicknames (:vr :3b-openvr)))

(in-package :trial-vr)

(defclass workbench (trial:main) ()
  (:default-initargs :clear-color (trial::vec 0.3 0.3 0.3 0)))

(trial:define-pool workbench
  :base 'trial:trial)

(trial:define-asset (workbench grid) trial:mesh
    (trial:make-line-grid 10 2 2))

(trial:define-asset (workbench cube) trial:mesh
    (trial:make-cube 0.2 ))

(trial:define-shader-subject grid (trial:vertex-entity trial:colored-entity)
  ()
  (:default-initargs :vertex-array (trial:asset 'workbench 'grid)))

(trial:define-shader-entity lines (trial:vertex-entity)
  ((line-width :initarg :line-width :initform 3.0 :accessor line-width))
  (:inhibit-shaders (trial:vertex-entity :vertex-shader)))

(defclass line-vertex (trial:vertex)
  ())

(defmethod initialize-instance :after ((lines lines) &key points)
  (let ((mesh (make-instance 'trial:vertex-mesh :vertex-type 'trial::normal-vertex)))
    (trial:with-vertex-filling (mesh)
      (loop for (a b) on points
            while b
            do (trial:vertex :location a :normal (trial::v- a b))
               (trial:vertex :location b :normal (trial::v- a b))
               (trial:vertex :location a :normal (trial::v- b a
                                                  ))
               (trial:vertex :location b :normal (trial::v- a b))
               (trial:vertex :location b :normal (trial::v- b a))
               (trial:vertex :location a :normal (trial::v- b a))))
    (setf (trial:vertex-array lines) (change-class mesh 'trial:vertex-array :vertex-form :triangles))))

(defmethod trial:paint :before ((lines lines) (target trial:shader-pass))
  (let ((program (trial:shader-program-for-pass target lines)))
    (setf (trial:uniform program "line_width") (float (line-width lines)))
    (setf (trial:uniform program "view_size") (trial::vec (trial:width trial:*context*) (trial:height trial:*context*)))))

(trial:define-class-shader (lines :vertex-shader)
  "layout(location = 0) in vec3 position;
layout(location = 1) in vec3 direction;

out vec2 line_normal;
uniform float line_width = 0.1;
uniform vec2 view_size = vec2(1852,2056);
uniform mat4 model_matrix;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

void main(){
  float aspect = view_size.x/view_size.y;
  mat4 PVM = projection_matrix * view_matrix * model_matrix;
  vec4 screen1 = PVM * vec4(position, 1);
  vec4 screen2 = PVM * vec4(position+direction, 1);
  vec2 clip1 = screen1.xy/screen1.w;
  vec2 clip2 = screen2.xy/screen2.w;
  clip1.x *= aspect;
  clip2.x *= aspect;
  line_normal = normalize(clip2 - clip1);
  line_normal = vec2(-line_normal.y, line_normal.x);
  line_normal.x /= aspect;
  gl_Position = screen1 + screen1.w * vec4(line_normal*line_width/view_size, 0, 0);
}")

(trial:define-class-shader (lines :fragment-shader)
  "in vec2 line_normal;
uniform float feather = 0.2;
out vec4 color;

void main(){
   color *= (1-length(line_normal))*16;
}")

(trial:define-shader-subject cube (trial:vertex-entity trial:colored-entity trial:textured-entity trial:located-entity trial:rotated-entity trial:selectable)
  ((vel :initform 0
        :accessor vel))
  (:default-initargs :vertex-array (trial:asset 'workbench 'cube)
                     :texture
                     (make-instance 'trial:texture
                                    :width 1024
                                    :height 1024
                                    :pixel-data
                                    (cl-xwd:shared-memory-raw-pointer
                                     (parse-integer
                                      (alexandria:read-file-into-string
                                       (merge-pathnames #p"vrx-utils/shared-memory-id"
                                                        (user-homedir-pathname)))))
                                    :pixel-type :unsigned-short-5-6-5
                                    :internal-format :rgb
                                    :levels 0)
                     :rotation (trial::vec (/ PI -2) 0 0)
                     :color (trial::vec3-random 0.2 0.8)
                     :location (trial::vec3 0 0.05 -0.4)))

(trial:define-handler (cube trial:tick) (trial::ev)
  (when (trial:allocated-p (trial:texture cube)) (trial:deallocate (trial:texture cube)))
  (trial:allocate (trial:texture cube))
  (let* ((loc (trial:location cube))
         (rot (trial:rotation cube))
         (speed (* (vel cube)
                   (if (trial:retained 'key :left-shift) 5 1)
                   (if (trial:retained 'key :left-alt) 1/5 1))))
    (cond ((trial:retained 'key :a)
           (decf (vx loc) (* speed (cos (vy rot))))
           (decf (vz loc) (* speed (sin (vy rot)))))
          ((trial:retained 'key :d)
           (incf (vx loc) (* speed (cos (vy rot))))
           (incf (vz loc) (* speed (sin (vy rot))))))
    (cond ((trial:retained 'key :w)
           (incf (vx loc) (* speed (sin (vy rot))))
           (decf (vz loc) (* speed (cos (vy rot))))
           (decf (vy loc) (* speed (sin (vx rot)))))
          ((trial:retained 'key :s)
           (decf (vx loc) (* speed (sin (vy rot))))
           (incf (vz loc) (* speed (cos (vy rot))))
           (incf (vy loc) (* speed (sin (vx rot))))))
    (cond ((trial:retained 'key :space)
           (incf (vy loc) speed))
          ((trial:retained 'key :c)
           (decf (vy loc) speed)))))

(defun create-framebuffer ()
  )

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
   :near-plane 0.1f0
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

(defun sb->3d (matrix)
  (if (typep matrix 'simple-array)
      (funcall #'3d-matrices:matn 4 4 (coerce matrix 'list))
      (3d-matrices:meye 4)))

(defun get-eye-pose (side)
  (vr::vr-system)
  (sb->3d (vr::get-eye-to-head-transform side)))

(defun get-eye-projection (side)
  (vr::vr-system)
  (sb->3d (vr::get-projection-matrix side 0.01f0 1000000.0f0)))

(let ((poses (make-array (list  vr::+max-tracked-device-count+) :initial-element 0)))
  (defun get-latest-hmd-pose ()
    (vr::vr-system)
    (vr::vr-compositor)
    (vr::wait-get-poses poses nil)
    (loop for device below vr::+max-tracked-device-count+
          for tracked-device = (aref poses device)
          when (getf tracked-device 'vr::pose-is-valid)
          do (setf (aref poses device)
                   (getf tracked-device 'vr::device-to-absolute-tracking))
          finally
          (return
            (sb->3d (aref poses vr::+tracked-device-index-hmd+))))))

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

(defmethod trial:start :before ((main workbench))
  "Set up OpenVR environment."
  (setf vr::*%init* (vr::vr-init :scene)))

(defmethod trial:finalize :after ((main workbench))
  "Shut down OpenVR environment."
  (vr::vr-shutdown-internal)
  (setf vr::*%init* nil))

(defparameter *left-render-pass* nil)
(defparameter *right-render-pass* nil)
(defparameter *head* nil)

(trial:define-asset (workbench trial::skybox) trial::image
    '(#p"nissi-beach/posx.jpg"
      #p"nissi-beach/negx.jpg"
      #p"nissi-beach/posy.jpg"
      #p"nissi-beach/negy.jpg"
      #p"nissi-beach/posz.jpg"
      #p"nissi-beach/negz.jpg")
  :target :texture-cube-map)

(progn
  (defmethod trial:setup-scene ((workbench workbench) scene)
    ;(trial:enter (make-instance 'grid) scene)
    (trial:enter (make-instance 'trial::skybox
                                :texture (trial:asset
                                          'workbench
                                          'trial::skybox))
                 scene)
    (trial:enter (make-instance 'cube) scene)
    ;(trial:enter (make-instance 'lines :points (list (trial::vec 0 0 0) (trial::vec 0 100 100) (trial::vec 100 0 0))) scene)
    (trial:enter (setf *head* (make-instance 'head)) scene)
    (trial:enter (setf *left-render-pass* (make-instance 'left-eye-render-pass)) scene)
    (trial:enter (setf *right-render-pass* (make-instance 'right-eye-render-pass)) scene))
  (trial:maybe-reload-scene))

(trial:define-shader-pass eye-render-pass (trial:render-pass)
  ((trial:color :port-type trial:output :attachment :color-attachment0 :texspec #1=(:target :texture-2d) )
   (trial:depth :port-type trial:output :attachment :depth-stencil-attachment :texspec #1#)))

(trial:define-shader-pass left-eye-render-pass (eye-render-pass)
  ())

(trial:define-shader-pass right-eye-render-pass (eye-render-pass)
  ())

(defun texture-id (eye-render-pass)
  (trial:data-pointer (cadar (trial:attachments (trial:framebuffer eye-render-pass)))))

(defun submit-to-compositor (eye-render-pass)
  (vr::submit
   (if (typep eye-render-pass 'left-eye-render-pass) :left :right)
   (list 'vr::handle (texture-id eye-render-pass)
                          'vr::type :open-gl
                          'vr::color-space :gamma)))

(defmethod trial:project-view ((camera head) ev)
                                        ;Sets up the projection-view matrix when we are using the head camera.
  (setf trial:*view-matrix* (3d-matrices:m*
                                        ;(get-eye-projection (current-eye camera))
                             (get-eye-pose (current-eye camera))
                             (hmd-pose camera)
                             )))

(defmethod trial:paint-with :around ((pass eye-render-pass) thing)
  (setf (current-eye *head*)  (if (typep pass 'left-eye-render-pass)
                                  :left :right))
 (trial:project-view *head* nil)
  (call-next-method))


(defun launch ()
  (sb-thread:make-thread (lambda () (trial:launch 'workbench :width 926 :height 1028))))

(setf vr::*%init nil
      vr::*system* nil
      vr::*chaperone* nil
      vr::*compositor* nil)
