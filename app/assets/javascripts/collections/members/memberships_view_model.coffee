class @MembershipsViewModel
  initialize: (admin, memberships, layers, collectionId) ->
    _self = @

    @collectionId = ko.observable(collectionId)

    @selectedLayer = ko.observable()

    @layers = ko.observableArray $.map(layers, (x) -> new Layer(x))

    # Where AnonymousMembership inherits from Membership
    membership_models = $.map(memberships.members, (x) -> new Membership(_self, x))
    membership_models.unshift(new AnonymousMembership(_self, memberships.anonymous))
    @memberships = ko.observableArray membership_models

    @admin = ko.observable admin

    @groupBy = ko.observable("Users")
    @groupByOptions = ["Users", "Layers"]


  destroyMembership: (membership) =>
    confirmation = Jed.sprintf(__("Are you sure you want to remove %s from the collection?"), membership.userDisplayName())

    if confirm(confirmation)
      $.post "/collections/#{collectionId}/memberships/#{membership.userId()}.json", {_method: 'delete'}, =>
        @memberships.remove membership
