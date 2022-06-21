use application "polytope";

use vars '$Q', '$normals', '$pts', '$dim', '$P', '$V_int', '$pts_Rd';

$Q=$ARGV[0]; #Grammatrix Q = B^T B
$dim=scalar(@{$Q});

#Compute the normal vectors of the Parallelepiped that contains vor(Lambda) --- the 'candidate body'
$normals =new Matrix(2*$dim, $dim+1);
for(my $i=0; $i<$dim; $i++){
    $normals->elem($i,0) = $Q->elem($i,$i);
    for(my $j=0; $j<$dim; $j++){
        $normals->elem($i,$j+1)=$Q->elem($i,$j);
    }
    $normals->elem($i+$dim,0) = $Q->elem($i,$i);
    for(my $j=0; $j<$dim; $j++){
        $normals->elem($i+$dim,$j+1)=-$Q->elem($i,$j);
    }
}

#The candidate body
$P = new Polytope(INEQUALITIES => $normals);

#Homogeneous coordinates of lattice vectos that might contribute to the Voronoi cell
$pts = $P->LATTICE_POINTS;


#Inhomogeneous coorinates of those
$pts_Rd=new Matrix(scalar(@{$pts}), $dim);
for(my $i=0; $i<scalar(@{$pts}); $i++){
    for(my $j=0; $j<$dim; $j++){
        $pts_Rd->elem($i,$j)=$pts->elem($i,$j+1);
    }
}

#Redundant inequalities of the Voronoi cell
$normals = new Matrix(scalar(@{$pts})-1, $dim+1);
my $null_vector = new Matrix(1,$dim);
my $j=0;
for(my $i=0; $i<scalar(@{$pts}); $i++){
    my $p = new Matrix($pts_Rd->row($i));
    if($p == $null_vector ) { $j=1;  next; }
    $p=(1/2)*$p;
    my $v=new Matrix(-$p*$Q);
    my $alpha = new Matrix($p*$Q*transpose($p));
    $v=$alpha|$v;
    $normals->row($i-$j)=$v->row(0);
}

#The transformed Voronoi cell, B^(-1)*V
$V_int=new Polytope(INEQUALITIES=>$normals);

#Sanity-Check
if($V_int->VOLUME != 1){
    print $V_int->VOLUME; print ", something went wrong.";
    return;
}

return $V_int
