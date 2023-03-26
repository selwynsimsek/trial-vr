(defsystem "trial-vr"
  :version "0.1.0"
  :author "Selwyn Simsek"
  :license ""
  :depends-on ("trial-glfw"
               "trial-assets"
               "trial-alloy"
               "trial-png"
               "trial-jpeg"
               "3b-openvr"
               "sb-cga"
               (:feature :linux "cl-steamworks")
               (:feature :linux "cl-ode")
               "bordeaux-threads"
               (:feature :linux "cl-xwd")
               (:feature :windows "com-on")
               "trial-assimp"
               ;"harmony-simple"
               )
  :defsystem-depends-on ("trivial-features"
                         "deploy")
  :build-operation "deploy-op"
  :build-pathname "trial-vr"
  :entry-point "org.shirakumo.fraf.trial.vr:launch"
  :depends-on ("trial-vr"
               "trial-png"
               "trial-jpeg"
               "rove")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "actor" :depends-on ("package"))
                 (:file "environment" :depends-on ("workbench" "package"))
                 (:file "emacs-cube" :depends-on ("package"))
                 (:file "com-structs"  :depends-on ("package") :if-feature :windows)
                 (:file "window-capture" :depends-on ("package") :if-feature :windows)
                 (:file "nv-dx-interop" :depends-on ("package") :if-feature :windows)
                 (:file "workbench" :depends-on ("package" "emacs-cube" "controllers" "helicopter"))
                 (:file "low-level" :depends-on ("package"))
                 (:file "event-handling" :depends-on ("package"))
                 (:file "physics" :depends-on ("package"))
                ; (:file "particle" :depends-on ("package"))
                 (:file "debug" :depends-on ("package"))
                 (:file "controllers" :depends-on ("package"))
                 (:file "helicopter" :depends-on ("package"))
                 (:file "ui" :depends-on ("package"))
                 (:file "rendering" :depends-on ("package" "ui")))))
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
