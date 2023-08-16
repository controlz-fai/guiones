

function find_outline(elt) {
    if (elt == null) {
        return false;
    }
    
    if (elt.className.match(/outline-\d+/) != null) {
        return elt;
    }
    
    return find_outline(elt.parentElement);
}

function toggle_outline(elt) {
    let eltoutline = find_outline(elt);
    if (!eltoutline)
        return;
    
    if (eltoutline.classList.contains('done')) {
        eltoutline.classList.remove('done');
    } else {
        eltoutline.classList.add('done');
    }
}

function setup_handlers() {
    document.addEventListener('click', (evt) => {
        toggle_outline(evt.target);        
    });
}

function on_ready(fn) {
  if (document.readyState !== 'loading') {
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

on_ready(setup_handlers);
