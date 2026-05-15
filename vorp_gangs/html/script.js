const { createApp } = Vue;

const app = createApp({
    data() {
        return {
            view: 'none', // none, management, invite
            gang: {
                name: '',
                balance: 0,
                members: {}
            },
            myRank: 1,
            ranks: {},
            inviteData: {
                gangName: '',
                gangId: 0
            }
        };
    },
    methods: {
        can(permission) {
            const rankData = this.ranks[this.myRank];
            return rankData && rankData.permissions.includes(permission);
        },
        shouldShowActions(member) {
            // Cannot take actions on yourself or those of equal/higher rank (except Leaders)
            if (member.char_id === this.gang.owner) return false;
            if (this.myRank === 5) return true; // Leader can do anything
            return this.myRank > member.rank;
        },
        invitePlayer() {
            fetch(`https://${GetParentResourceName()}/invitePlayer`, {
                method: 'POST',
                body: JSON.stringify({})
            });
        },
        promote(charId, currentRank) {
            fetch(`https://${GetParentResourceName()}/updateRank`, {
                method: 'POST',
                body: JSON.stringify({ charId: charId, newRank: currentRank + 1 })
            });
        },
        demote(charId, currentRank) {
            fetch(`https://${GetParentResourceName()}/updateRank`, {
                method: 'POST',
                body: JSON.stringify({ charId: charId, newRank: currentRank - 1 })
            });
        },
        kick(charId) {
            fetch(`https://${GetParentResourceName()}/kickMember`, {
                method: 'POST',
                body: JSON.stringify({ charId: charId })
            });
        },
        acceptInvite() {
            fetch(`https://${GetParentResourceName()}/acceptInvite`, {
                method: 'POST',
                body: JSON.stringify({ gangId: this.inviteData.gangId })
            });
            this.close();
        },
        declineInvite() {
            this.close();
        },
        close() {
            this.view = 'none';
            document.getElementById('app').style.display = 'none';
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST',
                body: JSON.stringify({})
            });
        }
    },
    mounted() {
        window.addEventListener('message', (event) => {
            const data = event.data;

            if (data.action === "openMenu") {
                this.gang = data.gang;
                this.myRank = data.myRank;
                this.ranks = data.ranks;
                this.view = 'management';
                document.getElementById('app').style.display = 'flex';
            }

            if (data.action === "showInvite") {
                this.inviteData.gangName = data.gangName;
                this.inviteData.gangId = data.gangId;
                this.view = 'invite';
                document.getElementById('app').style.display = 'flex';
            }

            if (data.action === "updateData") {
                this.gang = data.gang;
            }
        });

        window.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                this.close();
            }
        });
    }
});

app.mount('#app');
