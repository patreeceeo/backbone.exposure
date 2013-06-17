# Public: Extended version of Backbone's Model class. Added features:
#   "hardened attributes" - model will throw an error if you try to do anything
#                           with attributes that were not specified in the
#                           `defaults` hash or if you try to change the type of
#                           any such attribute.
#   "automatic accessors" - for each of the model's initial attributes there
#                           is a jQuery-style accessor method with the same
#                           name, which makes mocking models in unit tests
#                           easier and writing and reading the code more
#                           pleasant.
#
# attributes - an (plain) Object of initial attributes
# options - see backbone.js documentation

bump = (message) ->
  throw new Exception "Bump! #{message}"

with_each_attr = (thing, fn) ->
  if _.isObject(thing)
    fn key, thing[key] for key of thing
  else
    fn thing
  
Backbone.Bumpers =
  attributeKeys: (snapshot = @defaults) ->
    # Bind reference to original methods in outer scope.
    _get = @get
    _set = @set

    @get = (key, options...) ->
      unless key of snapshot
        bump "Attempting to `get()` with unknown key '#{key}'."
      _get.call this, key, options...
    @set = (arg1, options...) ->
      with_each_attr arg1, (key) ->
        unless key of snapshot
          bump "Attempting to `set()` with unknown key '#{arg1}'."
      _set.call this, arg1, options...

  attributeTypes: (snapshot = @defaults) ->
    _set = @set
    @set = (arg1, options...) ->
      with_each_attr arg1, (key, value) ->
        ref = snapshot[arg1]
        value = value or options[0]
        if ref? and ref.constructor isnt value.constructor
          bump """
            Attempting to `set()` with value of type
            '#{value.constructor}' is not allowed for key '#{arg1}'.
            """
      _set.call this, arg1, options...

add_accessors = (attributes = @attributes) ->
  # Create a new outer scope for each attribute containing the corresponding
  # attribute key.
  add_accessor_for = (attribute_key) =>
    # make sure we aren't clobbering/overriding any methods provided by Backbone
    if attribute_key of Backbone.Model.prototype
      bump """
        Attempting to create an accessor method ('#{attribute_key}')
        with the same name as an existing method.
        """
    # @constructor is SocialPromote.BaseModel (in this case)
    @constructor::[attribute_key] = (attribute_value, other_args...) ->
      if attribute_value?
        @set attribute_key, attribute_value, other_args...
      else
        @get attribute_key, other_args...
  add_accessor_for key for own key of attributes

Backbone.Nimble or= {}

class Backbone.Nimble.Model extends Backbone.Model
  constructor: (args...) ->
    super
    fn.apply this, args for fn in @constructors

class Backbone.Bumpers.Model extends Backbone.Nimble.Model
  constructors: [
    Backbone.Bumpers.attributeKeys
    Backbone.Bumpers.attributeTypes
  ]

