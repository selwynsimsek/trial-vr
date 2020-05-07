(defsystem "trial-vr"
  :version "0.1.0"
  :author "Selwyn Simsek"
  :license ""
  :depends-on ("trial-glfw"
               #+linux "trial-alloy"
               "3b-openvr"
               "sb-cga"
               #+linux "cl-steamworks"
               #+linux "cl-ode"
               "bordeaux-threads"
               #+linux "cl-xwd"
               #+windows "com-on"
               "trial-assimp"
               "harmony-simple")
  :defsystem-depends-on ("trivial-features"
                         "deploy")
  :build-operation "deploy-op"
  :build-pathname "trial-vr"
  :entry-point "org.shirakumo.fraf.trial.vr:launch"
  :depends-on ("trial-vr"
               "rove")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "actor")
                 (:file "environment" :depends-on ("workbench"))
                 (:file "emacs-cube")
                 #+windows (:file "com-structs")
                 #+windows (:file "window-capture")
                 #+windows (:file "nv-dx-interop")
                 (:file "workbench")
                 (:file "low-level")
                 (:file "rendering")
                 (:file "event-handling")
                 (:file "physics")
                 (:file "particle")
                 (:file "debug")
                 (:file "controllers"))))
  :description ""
  :in-order-to ((test-op (test-op "trial-vr/tests"))))

(defsystem "trial-vr/tests"
  :author "Selwyn Simsek"
  :license ""
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for trial-vr"
  :perform (test-op (op c) (symbol-call :rove :run c)))
