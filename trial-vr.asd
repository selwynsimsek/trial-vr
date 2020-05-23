(defsystem "trial-vr"
  :version "0.1.0"
  :author "Selwyn Simsek"
  :license ""
  :depends-on ("trial-glfw"
               "trial-assets"
               "trial-alloy"
               "3b-openvr"
               "sb-cga"
               (:feature :linux "cl-steamworks")
               (:feature :linux "cl-ode")
               "bordeaux-threads"
               (:feature :linux "cl-xwd")
               (:feature :windows "com-on")
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
                 (:file "com-structs" :if-feature :windows)
                 (:file "window-capture" :if-feature :windows)
                 (:file "nv-dx-interop" :if-feature :windows)
                 (:file "workbench")
                 (:file "low-level")
                 (:file "rendering")
                 (:file "event-handling")
                 (:file "physics")
                 (:file "particle")
                 (:file "debug")
                 (:file "controllers")
                 (:file "ui"))))
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
