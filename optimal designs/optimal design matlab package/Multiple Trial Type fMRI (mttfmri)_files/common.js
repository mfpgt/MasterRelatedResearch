if(typeof this.PINT==="undefined"){var PINT={}; }

/* FUNCTIONS *******************/

/* ADD CLASS **********/
// Format: $('.something').PINT_addClass('last');
$.fn.PINT_addClass = function(addClass) {
    if ( $(this).length ) {
        $(this).addClass(addClass);
    }
};

/* BANNER (ADD MASK) **********/
// Format: $('.target').PINT_banner();
$.fn.PINT_banner = function(exclude) {
    if ( $(this).length && !$(this).is(exclude) ) {
        $(this).each(function() {
            var maskCode = '<div class="mask">&nbsp;</div>';
            if ( $(this).children().hasClass('caption') ) {
                $(this).append(maskCode);
            }
        });
    }
};

/* INPUT: FOCUS/BLUR **********/
// Sets Focus/Blur on target INPUT
// Format: $('.input-name').PINT_focusBlur('Text to Swap');
$.fn.PINT_focusBlur = function(text) {
    if ( $(this).length ) {
        $(this).focus(function(){ 
            if ($(this).val() === text) {
                $(this).val('');
            }
        }).blur(function(){ 
            if ($(this).val() === '') { 
                $(this).val(text);
            }
        });
    }
};

/* MENU (TRIGGER+'DROP' BOX) **********/
// JS Controlled Main-Nav Dropdown (Overides CSS-Only dropdown) or show/hide something based on trigger
$.fn.PINT_menu = function() {
    
    $(this)
        .bind('mouseover', function(e) {
            if ( $(e.relatedTarget).is('.menu-box, .menu-box *') ) return false;
            $(this).addClass('hover').next().show();
        })
        .bind('mouseout', function(e) {
            if ( $(e.relatedTarget).is('.menu-box, .menu-box *') ) return false;
            $(this).removeClass('hover').next().hide();
        })
        .bind('click', function() {
            return false;
        })
    ;
    
    $('.menu-box').bind('mouseout', function(e) {
        if ( $(e.relatedTarget).is('.menu, .menu-box, .menu-box *') ) return false;
        $(this).hide().prev().removeClass('hover');
    });
    
};

/* PNG24 'FIX' FOR IE6 **********/
// IE6 doesn't support transparency for PNG24 images. This code corrects that.
// Note: this is not jQuery and should be included for IE6 support
PINT_pngFix = function() {
    var PINT_browser = navigator.userAgent.toLowerCase();
    if ( (PINT_browser.indexOf("msie 6.")!==-1) && (PINT_browser.indexOf("opera")===-1) ) {
        for (var i=0; i<document.images.length; i++) {
            var img = document.images[i]; var imgName = img.src.toUpperCase();
            if ( imgName.substring(imgName.length-3,imgName.length) == "PNG" ) {
                var imgID=img.id ? "id='"+img.id+"' ":""; var imgClass=img.className ? "class='"+img.className+"' ":""; var imgTitle=img.title ? "title='"+img.title+"' ":"title='"+img.alt+"' "; var imgStyle="display:inline-block;"+img.style.cssText;
                
                if (img.align=="left") imgStyle="float:left;"+imgStyle;
                if (img.align=="right") imgStyle="float:right;"+imgStyle;
                if (img.parentElement.href) imgStyle="cursor:hand;"+imgStyle;
                
                var strNewHTML="<span "+imgID+imgClass+imgTitle+"style=\""+"width:"+img.width+"px; height:"+img.height+"px;"+imgStyle+"; filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'"+img.src+"\',sizingMethod='scale');\"></span>";
                img.outerHTML=strNewHTML;i=i-1;
            }
        }
    }
};

/* TABLE 'ALTERNATE' ROW **********/
// Format: $('table').PINT_tableAltRow();
// Add alternating class based off modulus attribute
$.fn.PINT_tableAltRow = function(modulus) {
    if ( $(this).length ) {
        $(this).each(function(index) {
            if ( index % modulus == 0 && index > 1 ) {
                $(this).addClass('alt');
            }
        });
    }
};


/* INITIALIZE FUNCTIONS *******************/
PINT.init = function() {

    /* JS ENABLED - Target any element differently (CSS) if JS enabled/disabled **********/
    $('body').PINT_addClass('js-enabled');

    /* HOMEPAGE BANNER **********/
    $('.component-banner').PINT_banner('#h-banner-nomask');
    
    /* INPUT: 'FOCUS/BLUR' **********/
    $('.input-search').PINT_focusBlur('Search Site');

    /* MENU (TRIGGER+'DROP' BOX) **********/
    // JS Controlled Main-Nav Dropdown (Overides CSS-Only dropdown) or show/hide something based on trigger
    $('.menu').PINT_menu();
    
    /* PNG24 'FIX' FOR IE6 ********/
    //PINT_pngFix();
    
    /* MISC FIXES **********/
    // Add 'last' class to last element
	$('.nav li:last-child, #footer li:last-child, #utilitynav li:last-child, #breadcrumb li:last-child, #col1 .col:last-child, .tbl-generic tr:last-child').PINT_addClass('last'); 
    
    /* NAVIGATION FIXES **********/
    // Toggle class on LI so hover color 'sticks' when you move down to the dropdown    
    $('.nav > li').hover(function() { 
        $(this).toggleClass('hover');
    });
    
    /* TABLE 'ALTERNATE' ROW **********/
    $('.tbl-generic tbody tr').PINT_tableAltRow(2);
	
	/* PINTBOX **********/
	$('.pintbox').fancybox({ 'titleShow':false });
	$('.pintbox-iframe').fancybox({ 'width':'75%','height':'75%','autoScale':false,'transitionIn':'fade','transitionOut':'fade','type':'iframe'});
        
};

/* RUN FUNCTIONS *******************/
$(document).ready(function() {
  PINT.init();
});