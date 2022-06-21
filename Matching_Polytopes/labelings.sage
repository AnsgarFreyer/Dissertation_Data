#all the methods below assume G to be a vertex-labeled forest such that every vertex has at most one smaller neighbour.
#This is a method to ensure that this is the case:
def proper_labeling(G):
    l = list(G.breadth_first_search(0))
    p = []
    for i in l:
        p.append(i+1)
    sigma = Permutation(p).inverse()
    G.relabel(sigma)
    return G


# ----- The matching side -----


#Returns the edge of G containing the vertex with the minimal label and its minimal neighbour
def find_minimal_edge(G):
	
	if not G.edges():
		return
	vmin = -1
	for v in G.vertices():
		if G.neighbors(v)!=[]:
			vmin = v
			break
	
	return(vmin, min(G.neighbors(vmin)))

#Returns the matching obtained by greedily picking minimal edges.
#The resulting matching is almost perfect if the labeling of the graph is "from the root to the leafs"
def almost_perfect_matching(G):
	matching = []
	H = copy(G)

	while H.edges():
		e = find_minimal_edge(H)
		matching.append(e)
		H.delete_edges(H.edges_incident(e[0]))
		H.delete_edges(H.edges_incident(e[1]))

	return matching


#Recursive method that's called in st_labelings(G)
#Don't call this on its own...
def compute_standard_labelings(G,sigma):
	if not G.edges():
		standard_labelings.append(sigma)
		return
	
	apm = almost_perfect_matching(G)
	
	for e in apm:
		H = copy(G)
		H.delete_edge(e)
		new_sigma = copy(sigma)
		new_sigma.append(e)
		compute_standard_labelings(H,new_sigma)

#Computes the list of all standard labelings for G.		
def st_labelings(G):
	global standard_labelings
	standard_labelings = []
	compute_standard_labelings(G,[])
	return standard_labelings
	



# ----- The polar side -----


#Finds the parent of the non-isolated vertex with the highest label (which should be a leaf)
def find_center(G):
	maxleaf = -1
	for v in reversed(G.vertices()):
		if G.neighbors(v): 
			maxleaf = v
			break
	
	if maxleaf==-1:
		return -1

	#If maxleaf has more than one neighbor, it's not a leaf, so we messed up the labeling...
	if len(G.neighbors(maxleaf))>1:
		print("There's something wrong with omega!")
		return
	
	return G.neighbors(maxleaf)[0]

#Returns all edges incident to the parent of the leaf with the highest label.
#This is an almost perfect star.
def almost_perfect_star(G):
	vcenter = find_center(G)
	
	if vcenter==-1:
		return []

	return [(e[0],e[1]) for e in  G.edges_incident(vcenter)]

	
	
#Recursive method that's called in co_labelings(G)
#Don't call this on its own...
def compute_co_standard_labelings(G,sigma):
	if not G.edges():
		co_standard_labelings.append(sigma)
		return
	
	aps = almost_perfect_star(G)
	
	for e in aps:
		H = copy(G)
		H.delete_edge(e)
		new_sigma = copy(sigma)
		new_sigma.append(e)
		compute_co_standard_labelings(H,new_sigma)


#Computes the list of all standard labelings for G.		
def co_labelings(G):
	global co_standard_labelings
	co_standard_labelings = []
	compute_co_standard_labelings(G,[])
	return co_standard_labelings

	
	
	
	
