
# Aggregate defaults up the prototype chain in `snapshot`
aggregate_defaults = (current) ->
  defaults = {}
  while current?.defaults
    defaults = _.defaults {}, defaults, _.result(current, 'defaults')
    current = Object.getPrototypeOf current
  defaults 

window.Exposure =
  getMethodKeys: (object) ->
    proto = Object.getPrototypeOf object
    key for own key of proto when not 
        key of Backbone.Model.prototype and not
        key is 'constructor' and not
        key is 'defaults' and
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
    attributes = aggregate_defaults this
    @constructor::__accessors__ = {}
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
    methodKeys = Exposure.getMethodKeys @
    attributes = aggregate_defaults this
    @toJSON = (args...) =>
      json = _toJSON.apply(this, args)
      for key in methodKeys
        json[key] = @[key]()
      json
    
    for key in methodKeys when not key of @__accessors__
      if attributes[key]?
        if _.isArray attributes[key]
          @[key].apply(this, attributes[key])
        else
          @[key](attributes[key])
        delete attributes[key]
    
class Exposure.Model extends Backbone.Model
  constructor: (args...) ->
    super(args...)
    fn.apply this, args for fn in [
        Exposure.createAttributesForMethods
        Exposure.createMethodsForAttributes
    ]


