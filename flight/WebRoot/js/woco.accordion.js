(
	function($)
	{
		$.fn.accordionwoco = function(options)
		{
			return this.each(function() {
				var settings = $.extend(
				{
				multiExpand: false,
				slideSpeed: 500,
				dropDownIcon: '&#9660'
			 }, options );
        
			$(this).find(".accordion-header").unbind('click').click(
				function()
				{
					if(settings.multiExpand==false){
						if(!$(this).hasClass('accordion-header-active'))
						{
							$(this).parent().parent().parent().find(".accordion-header-active").removeClass('accordion-header-active');
							$(this).parent().parent().parent().find(".accordion-item-active").children(".accordion-content").slideUp(settings.slideSpeed);
							$(this).parent().parent().parent().find(".accordion-header-icon-active").removeClass("accordion-header-icon-active");
							$(this).parent().parent().parent().find(".accordion-item-active").removeClass("accordion-item-active");
						}
					}
					$(this).toggleClass("accordion-header-active");
					$(this).parent().toggleClass("accordion-item-active");
					$(this).next().slideToggle(settings.slideSpeed);
					$(this).children(".accordion-header-icon").toggleClass("accordion-header-icon-active");
				}
			);	
		});
		}
	}
(jQuery));