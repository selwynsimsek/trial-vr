(in-package :trial-vr)

(defclass workbench (trial:main) ()
  (:default-initargs :clear-color (trial::vec 0.3 0.3 0.3 0)))

(trial:define-pool workbench
  :base 'trial:trial)

(trial:define-asset (workbench grid) trial:mesh
    (trial:make-line-grid 10 2 2))

(trial:define-asset (workbench cube) trial:mesh
    (trial:make-cube 0.4))

(trial:define-shader-subject cube (trial:vertex-entity trial:colored-entity trial:textured-entity
                                                       trial:located-entity trial:rotated-entity
                                                       trial:selectable)
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
                     :location (trial::vec3 0 10 -60)))

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

(defmethod trial:start :before ((main workbench))
  "Set up OpenVR environment."
  (setf vr::*%init* (vr::vr-init :scene)))

(defmethod trial:finalize :after ((main workbench))
  "Shut down OpenVR environment."
  (vr::vr-shutdown-internal)
  (setf vr::*%init* nil))

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
    (trial:enter (make-instance 'trial::skybox
                                :texture (trial:asset
                                          'workbench
                                          'trial::skybox))
                 scene)
    (trial:enter (make-instance 'cube) scene)
    (trial:enter (setf *head* (make-instance 'head)) scene)
    (trial:enter (setf *left-render-pass* (make-instance 'left-eye-render-pass)) scene)
    (trial:enter (setf *right-render-pass* (make-instance 'right-eye-render-pass)) scene))
  (trial:maybe-reload-scene))


(defun texture-id (eye-render-pass)
  (trial:data-pointer (cadar (trial:attachments (trial:framebuffer eye-render-pass)))))

(defun submit-to-compositor (eye-render-pass)
  (vr::submit
   (if (typep eye-render-pass 'left-eye-render-pass) :left :right)
   (list 'vr::handle (texture-id eye-render-pass)
                          'vr::type :open-gl
                          'vr::color-space :gamma)))

(defun launch ()
  (bt:make-thread (lambda () (trial:launch 'workbench :width 926 :height 1028))))

(setf vr::*%init nil vr::*system* nil vr::*chaperone* nil vr::*compositor* nil)
