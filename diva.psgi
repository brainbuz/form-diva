use strict;
use warnings;

use Diva;

my $app = Diva->apply_default_middlewares(Diva->psgi_app);
$app;

