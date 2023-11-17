const utility = {
    community : {
        context: (new RegExp('.*?\/s\/','g')).exec(window.location.href) != null,
        is : function() {
            return this.context;
        }, 
        path : function() {
            let path = (new RegExp(':\/\/(.*\.com)\/([A-Za-z0-9]*\/)?s\/','g')).exec(window.location.href); 
            return this.context != null ? path[2] == undefined ? '' : path[2] : null;
        }
    },
}

export {
    utility
}