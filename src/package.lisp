(defpackage #:org.shirakumo.fraf.trial.vr
  (:use #:cl)
  (:local-nicknames (#:vr #:3b-openvr)
		    (#:trial #:org.shirakumo.fraf.trial)
                    (#:trial-assets #:org.shirakumo.fraf.trial.assets)
		    (#:alloy #:org.shirakumo.alloy)
		    (#:trial-alloy #:org.shirakumo.fraf.trial.alloy)
                    (#:simple-presentations #:org.shirakumo.alloy.renderers.simple.presentations)))

#+windows
(defpackage #:org.shirakumo.fraf.trial.vr.windows
  (:use #:cl)
  (:local-nicknames (#:com-on #:org.shirakumo.com-on)
                    (#:com-on.cffi #:org.shirakumo.com-on.cffi)
                    (#:trial-vr #:org.shirakumo.fraf.trial.vr)))


(defpackage #:org.shirakumo.fraf.trial.vr.user
  (:use #:cl #:org.shirakumo.fraf.trial.vr #+windows #:org.shirakumo.fraf.trial.vr.windows)
  (:local-nicknames (#:com-on #:org.shirakumo.com-on)
                    (#:com-on.cffi #:org.shirakumo.com-on.cffi)
                    (#:vr #:3b-openvr)
		    (#:trial #:org.shirakumo.fraf.trial)
                    (#:trial-vr #:org.shirakumo.fraf.trial.vr)
                    (#:trial-assets #:org.shirakumo.fraf.trial.assets)
		    (#:alloy #:org.shirakumo.alloy)
		    (#:trial-alloy #:org.shirakumo.fraf.trial.alloy))
  (:nicknames #:trial-vr.user)) ; naughty! not package local
