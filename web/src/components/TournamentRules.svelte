<script>
  let activeSection = $state('general');

  const rules = {
    general: {
      title: 'General Rules',
      icon: 'fas fa-gavel',
      items: [
        'Teams must consist of 2-4 players',
        'Each team must pay the registration fee before competing',
        'Teams cannot change members during active tournaments',
        'Unsportsmanlike conduct will result in disqualification',
        'All players must be online and available during match times',
        'Teams that forfeit matches will be eliminated from the tournament'
      ]
    },
    roles: {
      title: 'Team Roles',
      icon: 'fas fa-users',
      items: [
        '<strong>Captain:</strong> Team leader, manages team settings and members, responsible for team decisions',
        '<strong>Driver:</strong> Primary race participant, must have excellent driving skills and vehicle knowledge',
        '<strong>Navigator:</strong> Co-pilot and strategist, provides route guidance and tactical support',
        '<strong>Mechanic:</strong> Vehicle tuning and maintenance specialist, optimizes car performance'
      ]
    },
    format: {
      title: 'Tournament Format',
      icon: 'fas fa-trophy',
      items: [
        'Single elimination bracket tournament',
        'Best of 3 races per match (Bo3)',
        'Winners advance to the next round',
        'Prize pool distributed among top teams',
        'Matches are scheduled at predetermined times',
        'Teams have 15 minutes to prepare for each race'
      ]
    },
    vehicles: {
      title: 'Vehicle Regulations',
      icon: 'fas fa-car',
      items: [
        'Sports, Super, and Sports Classic vehicles allowed',
        'No modifications beyond standard tuning',
        'Vehicle must be owned by a team member',
        'Random vehicle inspections may occur',
        'Armored vehicles are strictly prohibited',
        'All vehicles must pass technical inspection before races'
      ]
    },
    conduct: {
      title: 'Code of Conduct',
      icon: 'fas fa-handshake',
      items: [
        'Respect all players, staff, and officials',
        'No cheating, exploiting, or use of third-party software',
        'No intentional ramming or blocking (unless strategic)',
        'Follow all FiveM server rules and regulations',
        'Report any rule violations to tournament officials',
        'Maintain professional communication in all channels'
      ]
    },
    scoring: {
      title: 'Scoring System',
      icon: 'fas fa-calculator',
      items: [
        'Race winner receives 10 points',
        '2nd place receives 8 points',
        '3rd place receives 6 points',
        '4th place receives 4 points',
        'Additional points for fastest lap (2 points)',
        'Penalty deductions for rule violations'
      ]
    }
  };

  function setActiveSection(section) {
    activeSection = section;
  }
</script>

<div class="max-w-7xl mx-auto p-6">
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-white mb-2">Tournament Rules & Regulations</h1>
    <p class="text-gray-400">Read and understand all rules before participating</p>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
    <!-- Navigation Sidebar -->
    <div class="lg:col-span-1">
      <div class="card sticky top-6">
        <h3 class="text-lg font-semibold text-white mb-4">Sections</h3>
        <nav class="space-y-2">
          {#each Object.entries(rules) as [key, rule]}
            <button
              class="w-full text-left p-3 rounded-lg transition-all duration-200 flex items-center gap-3 {activeSection === key ? 'bg-primary-500 text-white' : 'text-gray-400 hover:text-white hover:bg-white/10'}"
              onclick={() => setActiveSection(key)}
            >
              <i class="{rule.icon} text-sm"></i>
              <span class="text-sm font-medium">{rule.title}</span>
            </button>
          {/each}
        </nav>
      </div>
    </div>

    <!-- Content Area -->
    <div class="lg:col-span-3">
      <div class="card">
        <div class="mb-6">
          <h2 class="text-2xl font-bold text-white flex items-center gap-3 mb-2">
            <i class="{rules[activeSection].icon} text-primary-500"></i>
            {rules[activeSection].title}
          </h2>
        </div>

        <div class="space-y-4">
          {#each rules[activeSection].items as item}
            <div class="flex items-start gap-3 p-4 bg-white/5 rounded-lg hover:bg-white/10 transition-colors">
              <div class="w-2 h-2 bg-primary-500 rounded-full mt-2 flex-shrink-0"></div>
              <p class="text-gray-300 leading-relaxed">{@html item}</p>
            </div>
          {/each}
        </div>

        <!-- Additional Information Based on Section -->
        {#if activeSection === 'general'}
          <div class="mt-8 p-6 bg-blue-500/10 border border-blue-500/30 rounded-lg">
            <h4 class="text-lg font-semibold text-blue-400 mb-3 flex items-center gap-2">
              <i class="fas fa-info-circle"></i>
              Important Notice
            </h4>
            <p class="text-gray-300">
              All participants must read and agree to these rules before joining any tournament. 
              Violation of any rule may result in warnings, point deductions, or disqualification 
              from the tournament. Rules are subject to change with prior notice.
            </p>
          </div>
        {/if}

        {#if activeSection === 'roles'}
          <div class="mt-8 p-6 bg-yellow-500/10 border border-yellow-500/30 rounded-lg">
            <h4 class="text-lg font-semibold text-yellow-400 mb-3 flex items-center gap-2">
              <i class="fas fa-lightbulb"></i>
              Role Selection Tips
            </h4>
            <p class="text-gray-300">
              Choose roles based on your team's strengths. A good captain should have leadership 
              skills, drivers need excellent racing ability, navigators should know the city well, 
              and mechanics should understand vehicle tuning and performance optimization.
            </p>
          </div>
        {/if}

        {#if activeSection === 'vehicles'}
          <div class="mt-8 p-6 bg-red-500/10 border border-red-500/30 rounded-lg">
            <h4 class="text-lg font-semibold text-red-400 mb-3 flex items-center gap-2">
              <i class="fas fa-exclamation-triangle"></i>
              Vehicle Inspection
            </h4>
            <p class="text-gray-300">
              Random vehicle inspections will be conducted to ensure compliance. Teams found 
              using illegal modifications or prohibited vehicles will face immediate disqualification. 
              Make sure your vehicles meet all requirements before race day.
            </p>
          </div>
        {/if}
      </div>

      <!-- Quick Actions -->
      <div class="card mt-6">
        <h3 class="text-lg font-semibold text-white mb-4">Need Help?</h3>
        <div class="flex gap-4 flex-wrap">
          <button class="btn btn-primary">
            <i class="fas fa-question-circle"></i>
            Contact Support
          </button>
          <button class="btn btn-secondary">
            <i class="fas fa-download"></i>
            Download Rules PDF
          </button>
          <button class="btn btn-outline">
            <i class="fas fa-comments"></i>
            Community Discord
          </button>
        </div>
      </div>
    </div>
  </div>
</div>