# == Class: bareos::profile::director::pool
# Some default pools
class bareos::profile::director::pool {
  bareos::director::pool { 'Differential':
    pool_type        => 'Backup',
    recycle          => true,
    auto_prune       => true,
    volume_retention => '90 days',
    label_format     => 'Differential-',
  }

  bareos::director::pool { 'Full':
    pool_type        => 'Backup',
    recycle          => true,
    auto_prune       => true,
    volume_retention => '365 days',
    label_format     => 'Full-',
  }

  bareos::director::pool { 'Incremental':
    pool_type        => 'Backup',
    recycle          => true,
    auto_prune       => true,
    volume_retention => '30 days',
    label_format     => 'Incremental-',
  }

  bareos::director::pool { 'Scratch':
    pool_type => 'Scratch',
  }
}
