function loadURL(url) {
    var iFrame;
    iFrame = document.createElement("iframe");
    iFrame.setAttribute("src", 'umdi://bluno/'+url);
    iFrame.setAttribute("style", "display:none;");
    iFrame.setAttribute("height", "0px");
    iFrame.setAttribute("width", "0px");
    iFrame.setAttribute("frameborder", "0");
    document.body.appendChild(iFrame);
    // 发起请求后这个iFrame就没用了，所以把它从dom上移除掉
    iFrame.parentNode.removeChild(iFrame);
    iFrame = null;
}


var umdi = {};


umdi.status = function(status){

    document.getElementById('status').innerHTML = status;

}

umdi.scan = function(){

    loadURL('scan');
    
    
}

umdi.connect = function(uuid){
    loadURL('connect/'+uuid);

}

umdi.write = function(cmd){
    loadURL('write/'+cmd);


}