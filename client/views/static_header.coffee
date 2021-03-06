# Used on static pages to animate the header elements. Pass in the header DOM
# element when initializing:
#
#   new StaticHeader el: $('#theme-header')
#
class exports.StaticHeader extends Backbone.View

  # Sets up the animation.
  render: ->
    @props     = @$ '.icon-prop'
    @propCount = @props.length

    @queueNextAnimation()

    this

  # Performs an animation; chooses a header prop and random and changes it to
  # a different state. After completion, sets up the next animation to happen
  # in three seconds.
  #
  # If the user navigates away from the root page, this animation is not
  # performed, no next animation will be queued.
  #
  performAnimation: =>
    return false unless $('#page-view.root').length

    randomIndex  = Math.floor( Math.random() * @propCount )
    selectedProp = @props.eq randomIndex

    # Ignore any attempt to animate the eco buildings layer; we will change
    # that into a quarry when the ground layer changes to "dry".
    return @performAnimation() if selectedProp.hasClass 'eco-buildings'

    @performSwap(selectedProp)
    @performSwap($ '.eco-buildings') if selectedProp.hasClass 'ground'

    @queueNextAnimation()

  # Queues the next animation to happen in three seconds.
  queueNextAnimation: ->
    _.delay @performAnimation, 3000

  # Swaps the active and inactive icons for a prop.
  performSwap: (prop) ->
    toHide = prop.find('.active')
    toShow = prop.find('.inactive').first()

    toHide.removeClass('active').addClass('inactive').fadeOut 1000
    toShow.removeClass('inactive').addClass('active').fadeIn  1000
