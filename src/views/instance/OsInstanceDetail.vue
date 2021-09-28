<template>
  <a-card :bordered="false">

    <a-tabs :defaultActiveKey="selectKey">
      <a-tab-pane tab="基本信息" key="1" forceRender>
        <basic-info :dataSource="dataSource"/>
      </a-tab-pane>

      <a-tab-pane tab="控制臺" key="2" forceRender>
        <console :dataSource="dataSource"/>
      </a-tab-pane>

      <a-tab-pane tab="操作日志" key="3" forceRender>
        <operation-log/>
      </a-tab-pane>

    </a-tabs>
  </a-card>
</template>

<script>

  import BasicInfo from './details/basicInfo'
  import Console from './details/console'
  import OperationLog from './details/operationLog'

  export default {
    name: 'OsInstanceDetail',
    components: { OperationLog, Console, BasicInfo},
    data() {
      return {
        selectKey: '1',
      }
    },
    props:{
      dataSource:{
        type: Object,
        default: ()=>{},
        required: false
      }
    },
    created(){
     this.loadData(1);
    },
    methods: {
      loadData(arg){
        this.dataSource = this.$route.params;
        if(this.dataSource.selectKey){
          this.selectKey = this.dataSource.selectKey;
        }
      }

    },
  }
</script>

<style scoped>

</style>