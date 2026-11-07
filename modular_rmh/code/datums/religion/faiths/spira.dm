// RMH EDIT: the faiths of Spira, one per tier of the pantheon. Each god keeps a separate cult,
// and the myth varies slightly from cult to cult.

/datum/faith/spira
	abstract_type = /datum/faith/spira

/datum/faith/spira/primordials
	name = "The Primordials"
	desc = "Gaedon, who forced Paradise out of the primordial chaos, and Saelion, who brought life to it and \
	imprisoned his creator. Their cults hate each other: to one, Saelion is the usurper; to the other, the patron of all life."
	godhead = /datum/patron/spira/primordial/saelion
	preference_accessible = TRUE

/datum/faith/spira/greater
	name = "The Greater Gods"
	desc = "The first servants of Gaedon: Sirokel who made the stars, Naverae who named all things, \
	and Ragelia who fought the chaos. They were broken by the war within the pantheon, but they endure."
	godhead = /datum/patron/spira/greater/sirokel
	preference_accessible = TRUE

/datum/faith/spira/lesser
	name = "The Lesser Gods"
	desc = "Smaller servants, more insignificant but equally valuable, who took up the tasks the gods could not. \
	Chief among them is Lunestra, who keeps the hourglass of the dead."
	godhead = /datum/patron/spira/lesser/lunestra
	preference_accessible = TRUE
