<template>
  <a-card :bordered="false">

    <a-tabs :defaultActiveKey="selectKey">
      <a-tab-pane tab="基本信息" key="1" forceRender>
        <basic-info :dataSource="dataSource"/>
      </a-tab-pane>

      <a-tab-pane tab="控制臺" key="2" forceRender>
        <div class="ant-alert ant-alert-info" :style="{marginBottom:'10px'}" >
          <a type="primary" @click="openUrlNewWin" >點擊此處只顯示控制台 </a><span> 要退出全屏模式，請點擊瀏覽器的後退按鍵</span>
        </div>
        <console :dataSource="dataSource" ref="console"/>
      </a-tab-pane>

      <a-tab-pane tab="操作日誌" key="3" forceRender>
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
      },
      openUrlNewWin(){
        this.$refs.console.openUrlNewWin();
      }

    },
  }
</script>

<style scoped>

</style>