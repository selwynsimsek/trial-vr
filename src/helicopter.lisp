;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Load in the black hawk

(in-package #:org.shirakumo.fraf.trial.vr)

;; (trial:define-asset (trial-assets::workbench helicopter-mesh-35) trial::mesh
;;     (gethash
;;      "Mesh_35"
;;      (trial:meshes
;;       (trial:read-geometry
;;        (asdf:system-relative-pathname :trial-assets #p"data/black-hawk-wavefront/asset.obj")
;;        :wavefront))))

;; (trial:define-asset (trial-assets::workbench helicopter-seats-diffuse) trial::image
;;     #p"material_35_baseColor.jpeg")

;; (trial:define-shader-entity helicopter-seats
;;     (trial:vertex-entity trial:textured-entity trial:located-entity trial:rotated-entity trial:selectable)
;;   ()
;;   (:default-initargs :texture (trial:// 'trial-assets::workbench 'helicopter-seats-diffuse) 
;;                      :vertex-array  (trial:// 'trial-assets::workbench 'helicopter-mesh-35
;;                                               )
;;                      :name :helicopter-seats
;;                      :location (trial::vec3 100.0 1000.0 100.0)))
