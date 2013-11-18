/*
 * jQuery jSlots Plugin
 * http://matthewlein.com/jslot/
 * Copyright (c) 2011 Matthew Lein
 * Version: 1.0.2 (7/26/2012)
 * Dual licensed under the MIT and GPL licenses
 * Requires: jQuery v1.4.1 or later
 */

(function($){

    $.jSlots = function(el, options){

        var base = this;

        base.$el = $(el);
        base.el = el;

        base.$el.data("jSlots", base);

        base.init = function() {

            base.options = $.extend({}, $.jSlots.defaultOptions, options);

            base.setup();            
            base.playSlots();
        };


        // --------------------------------------------------------------------- //
        // DEFAULT OPTIONS
        // --------------------------------------------------------------------- //

        $.jSlots.defaultOptions = {
            number : 1,          // Number: number of slots
            winnerNumber : 1,    // Number or Array: list item number(s) upon which to trigger a win, 1-based index, NOT ZERO-BASED
            spinner : '',        // CSS Selector: element to bind the start event to
            spinEvent : 'click', // String: event to start slots on this event
            onStart : $.noop,    // Function: runs on spin start,
            onEnd : $.noop,      // Function: run on spin end. It is passed (finalNumbers:Array). finalNumbers gives the index of the li each slot stopped on in order.
            onWin : $.noop,      // Function: run on winning number. It is passed (winCount:Number, winners:Array)
            easing : 'swing',    // String: easing type for final spin
            time : 7000,         // Number: total time of spin animation
            loops : 6,            // Number: times it will spin during the animation
            isDebug : false
        };

        // --------------------------------------------------------------------- //
        // VARS
        // --------------------------------------------------------------------- //

        base.isSpinning = false;
        base.spinSpeed = 0;
        base.winCount = 0;
        base.doneCount = 0;

        base.$liHeight = 0;
        base.$liWidth = 0;

        base.winners = [];
        base.allSlots = [];        

        // --------------------------------------------------------------------- //
        // FUNCTIONS
        // --------------------------------------------------------------------- //


        base.setup = function() {

            // set sizes

            var $list = base.$el;
            var $li = $list.find('li').first();

            base.$liHeight = $li.outerHeight();
            base.$liWidth = $li.outerWidth();

            base.liCount = base.$el.children().length;

            base.listHeight = base.$liHeight * base.liCount;
            base.liOffset = base.$liHeight;

            base.increment = (base.options.time / base.options.loops) / base.options.loops;

            $list.css('position', 'relative');

            $li.clone().appendTo($list);

            base.$wrapper = $list.wrap('<div class="jSlots-wrapper"></div>').parent();

            // remove original, so it can be recreated as a Slot
            base.$el.remove();

            // clone lists
            for (var i = base.options.number - 1; i >= 0; i--){
                base.allSlots.push( new base.Slot() );
            }

        };

        // Slot contstructor
        base.Slot = function() {

            this.spinSpeed = base.increment;
            this.el = base.$el.clone().appendTo(base.$wrapper)[0];
            this.$el = $(this.el);
            this.loopCount = 0;
            this.number = 0;

        };


        var __nativeST__ = window.setTimeout;
        window.setTimeout = function (vCallback, nDelay /*, argumentToPass1, argumentToPass2, etc. */) {
          var oThis = this, aArgs = Array.prototype.slice.call(arguments, 2);
          return __nativeST__(vCallback instanceof Function ? function () {
            vCallback.apply(oThis, aArgs);
          } : vCallback, nDelay);
        };

        function getIndexByOffset(offset, height){
            var index = offset !== undefined ? offset/75 : 0;
            //console.log('offset: ' + offset + ' height: ' + height + ' num: ' + index);
            return Math.round(index);
        }

        function getWidthByIndex($parent, index){
            //$('ul li span').eq(2).width();
            //console.log($parent.find('li').eq(0));
            var width = $parent.find('li span').eq(index-1).width();
            if(base.options.isDebug){
                console.log('index: ' + index + ' width: ' + width);
            }

            return width;
        };

        base.Slot.prototype = {

            // do one rotation
            spinEm : function(offset) {

                var that = this;
                var startOffset = -offset || -base.listHeight;
                var endOffset = startOffset + base.liOffset;                                
                
                var ind = getIndexByOffset(offset, base.listHeight);

                ulWidth = getWidthByIndex(that.$el, ind);

                that.$el
                .css( 'top', startOffset )
                .animate( { 'top' : endOffset + 'px', 'width': ulWidth + 'px' }, base.increment, 'linear', function() {
                    setTimeout.call(that, that.spinEm, 2000, -endOffset);
                });    
            }
        };

        base.playSlots = function() {

            base.isSpinning = true;
            base.winCount = 0;
            base.doneCount = 0;
            base.winners = [];

            if ( $.isFunction(base.options.onStart) ) {
                base.options.onStart();
            }

            $.each(base.allSlots, function(index, val) {
                this.spinSpeed = 0;
                this.loopCount = 0;
                this.spinEm();
            });

        };

        // Run initializer
        base.init();
    };


    // --------------------------------------------------------------------- //
    // JQUERY FN
    // --------------------------------------------------------------------- //

    $.fn.jSlots = function(options){
        if (this.length) {
            return this.each(function(){
                (new $.jSlots(this, options));
            });
        }
    };

})(jQuery);