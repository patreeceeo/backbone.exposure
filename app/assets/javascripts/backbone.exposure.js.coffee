
with_each_attr = (thing, fn) ->
  if _.isObject(thing)
    fn key, thing[key] for key of thing
  else
    fn thing

inherit = (key, current) ->
  value = {}
  while _.isFunction(current?[key]) or _.isObject(current?[key])
    value = _.defaults {}, value, _.result(current, key)
    current = Object.getPrototypeOf current
  value

window.Exposure =
  getMethodKeys: (object) ->
    proto = Object.getPrototypeOf object
    key for own key of proto when proto isnt Backbone.Model.prototype and
        key isnt 'constructor' and
        key isnt 'defaults' and
        _.isFunction proto[key]

  makeGetterSetterFor: (key) ->
    (value, options...) ->
      if value?
        @set key, value, options...
      else
        @get key, options...

  createMethodsForAttributes: () ->
    # Create a new outer scope for each attribute containing
    # the corresponding attribute key.
    attributes = inherit 'defaults', this
    @constructor::__accessors__ = inherit '__accessors__', @constructor.prototype
    createMethodFor = (key) =>
      # Make sure we aren't clobbering/overriding any methods
      # provided by Backbone.
      if key of Backbone.Model.prototype
        Throw new Exception """
          Attempting to create an accessor method for key '#{key}'
          with the same name as a statically-defined method.
          """
      @constructor::[key] = Exposure.makeGetterSetterFor(key)
      @constructor::__accessors__[key] = @constructor::[key]
    createMethodFor key for own key of attributes when not @[key]

  createAttributesForMethods: () ->
    _toJSON = @toJSON
    methodKeys = @expose_methods_as_attributes or []
    @toJSON = (args...) =>
      json = _toJSON.apply(this, args)
      for key in methodKeys 
        try 
          json[key] = @[key]()
        catch e
          console.log "Uh oh, model method #{key}() requires arguments?"
      json

    _set = @set
    @set = (first_arg, options...) =>
      with_each_attr first_arg, (key, value) =>
        if key in (@expose_methods_as_attributes or [])
          @[key](value or options[1])
        else
          _set.call(this, first_arg, options...)
 
class Exposure.Model extends Backbone.Model
  constructor: (args...) ->
    super(args...)
    fn.apply this, args for fn in [
        Exposure.createAttributesForMethods
        Exposure.createMethodsForAttributes
    ]


